/**
 *  AppDelegate.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import SwifterMac
import iTunesScripting

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var currentAccount: NSMenuItem!
    @IBOutlet weak var tweetMenu: NSMenuItem!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    let userDefaults: UserDefaults = UserDefaults.standard

    var twitterClient: TwitterClient = TwitterClient.shared

    let playerInfo: iTunesPlayerInfo = iTunesPlayerInfo()

    override init() {
        super.init()

        let defaultSettings: [String : Any] = [
            "TweetFormat" : "#NowPlaying {{Title}} by {{Artist}} from {{Album}}",
            "TweetWithImage" : true,
            "AutoTweet" : false,
            ]
        self.userDefaults.register(defaults: defaultSettings)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        // Defines get URL handler
        NSAppleEventManager.shared().setEventHandler(self,
                                                     andSelector: #selector(self.handleEvent(_:withReplyEvent:)),
                                                     forEventClass: AEEventClass(kInternetEventClass),
                                                     andEventID: AEEventID(kAEGetURL))

        if let button = self.statusItem.button {
            let image = NSImage(named: NSImage.Name("StatusBarIcon"))
            image?.isTemplate = true
            button.image = image
        }

        self.statusItem.menu = self.menu

        self.updateTwitterAccount()
        let notificationCenter: NotificationCenter = NotificationCenter.default
        var observer: NSObjectProtocol!
        observer = notificationCenter.addObserver(forName: .alreadyAccounts, object: nil, queue: nil, using: { notification in
            self.updateTwitterAccount()
            notificationCenter.removeObserver(observer)
        })

        if self.userDefaults.bool(forKey: "AutoTweet") {
            let notificationObserver: NotificationObserver = NotificationObserver()
            notificationObserver.addObserver(self,
                                             name: .iTunesPlayerInfo,
                                             selector: #selector(self.handleNowPlaying(_:)),
                                             object: nil,
                                             distributed: true)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func handleEvent(_ event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        // Cell SwifterMac handler
        Swifter.handleOpenURL(URL(string: event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))!.stringValue!)!)
    }

    @objc func handleNowPlaying(_ notification: Notification) {
        let musicInfo: Dictionary = notification.userInfo!
        if (musicInfo["Player State"]! as! String != "Playing") {
            return
        }

        self.tweetNowPlaying(by: self.twitterClient.current)
    }

    @IBAction func showPreferences(_ sender: Any) {
        PreferencesWindowController.shared.showWindow(sender)
    }

    @IBAction func tweetByCurrentAccount(_ sender: NSMenuItem) {
        self.tweetNowPlaying(by: self.twitterClient.current)
    }

    @objc func tweetBySelectingAccount(_ sender: NSMenuItem) {
        let account = self.twitterClient.accounts[sender.title]
        self.tweetNowPlaying(by: account)
    }

    func tweetNowPlaying(by twitterAccounts: TwitterClient.Account?) {
        let tweetFailureHandler: Swifter.FailureHandler = { error in
            let err = error as! SwifterError

            let errMsg = err.message.components(separatedBy: ", ")
            let errRes = errMsg[1].components(separatedBy: ": ")

            let resData = errRes[1].data(using: .utf8, allowLossyConversion: false)!
            let jsonData = try! JSONSerialization.jsonObject(with: resData, options: .mutableContainers)
            let json = JSON(jsonData)

            let jsonErrors: [JSON] = json.object!["errors"]!.array!

            var msg: String = ""
            for jsonError in jsonErrors {
                msg.append(jsonError.object!["message"]!.string!)
                msg.append("\r")
            }

            let alert = NSAlert(message: "Tweet failed!",
                                informative: msg,
                                style: .warning)
            alert.runModal()
        }

        do {
            try self.postTweet(with: twitterAccounts, failure: tweetFailureHandler)
        } catch NPTError.NotLogin {
            let alert = NSAlert(message: "Not logged in!",
                                informative: "Please login in Preferences -> Accounts.",
                                style: .warning)
            alert.runModal()
        } catch NPTError.NotRunningiTunes {
            let alert = NSAlert(message: "Not runnning iTunes.",
                                style: .informational)
            alert.runModal()
        } catch NPTError.NotExistTrack {
            let alert = NSAlert(message: "Not exist music.",
                                style: .informational)
            alert.runModal()
        } catch let error {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }

    func postTweet(with twitterAccount: TwitterClient.Account?, failure: Swifter.FailureHandler? = nil) throws {
        if !self.twitterClient.existAccount {
            throw NPTError.NotLogin
        }

        self.playerInfo.updateTrack()

        if !self.playerInfo.isRunningiTunes {
            throw NPTError.NotRunningiTunes
        }

        if !self.playerInfo.existTrack {
            throw NPTError.NotExistTrack
        }

        let currentTrack: iTunesPlayerInfo.Track = self.playerInfo.currentTrack!

        let tweetText = self.createTweetText(from: currentTrack)

        if self.userDefaults.bool(forKey: "TweetWithImage") {
            self.twitterClient.tweet(account: twitterAccount!, text: tweetText, with: currentTrack.artwork, failure: failure)
        } else {
            self.twitterClient.tweet(account: twitterAccount!, text: tweetText, failure: failure)
        }
    }

    func createTweetText(from track: iTunesPlayerInfo.Track) -> String {
        var format = self.userDefaults.string(forKey: "TweetFormat")!

        let convertDictionary: [String : String] = [
            "{{Title}}" : track.title!,
            "{{Artist}}" : track.artist!,
            "{{Album}}" : track.album!,
            "{{AlbumArtist}}" : track.albumArtist!,
            "{{BitRate}}" : String(track.bitRate!),
        ]

        for (from,to) in convertDictionary {
            while let range = format.range(of: from) {
                format.replaceSubrange(range, with: to)
            }
        }

        return format
    }

    func updateTwitterAccount() {
        if !self.twitterClient.existAccount {
            self.currentAccount.title = "Not Login..."
            self.currentAccount.image = NSImage(named: .user)
            self.tweetMenu.submenu = nil
            return
        }

        if self.twitterClient.accountIDs.count > 1 {
            let menu = NSMenu()
            for userID in self.twitterClient.accountIDs {
                let twitterAccount = self.twitterClient.accounts[userID]
                let menuItem = NSMenuItem()
                menuItem.title = (twitterAccount?.name)!
                menuItem.action = #selector(self.tweetBySelectingAccount(_:))
                menu.addItem(menuItem)
            }
            self.tweetMenu.submenu = menu
        } else {
            self.tweetMenu.submenu = nil
        }

        self.currentAccount.title = self.twitterClient.current!.name
        self.currentAccount.fetchImage(url: self.twitterClient.current!.avaterUrl, rounded: true)
    }

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.identifier == NSUserInterfaceItemIdentifier("TweetNowPlaying") {
            return self.twitterClient.existAccount
        }

        return true
    }
}
