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
    @IBOutlet weak var currentSeparator: NSMenuItem!
    @IBOutlet weak var tweetMenu: NSMenuItem!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    let userDefaults: UserDefaults = UserDefaults.standard

    let twitterAccounts: TwitterAccounts = TwitterAccounts()

    var playerInfo: iTunesPlayerInfo = iTunesPlayerInfo()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        // Defines get URL handler
        NSAppleEventManager.shared().setEventHandler(self,
                                                     andSelector: #selector(self.handleEvent(_:withReplyEvent:)),
                                                     forEventClass: AEEventClass(kInternetEventClass),
                                                     andEventID: AEEventID(kAEGetURL))

        let defaultSettings: [String : Any] = [
            "TweetFormat" : "#NowPlaying {{Title}} by {{Artist}} from {{Album}}",
            "TweetWithImage" : true,
            "AutoTweet" : false,
            "CurrentAccount" : "0",
            ]
        self.userDefaults.register(defaults: defaultSettings)

        if let button = self.statusItem.button {
            let image = NSImage(named: NSImage.Name("StatusBarIcon"))
            image?.isTemplate = true
            button.image = image
        }
        self.statusItem.menu = self.menu

        if self.userDefaults.bool(forKey: "AutoTweet") {
            let notificationObserver: NotificationObserver = NotificationObserver()
            notificationObserver.addObserver(self,
                                             name: .iTunesPlayerInfo,
                                             selector: #selector(AppDelegate.handleNowPlaying(_:)),
                                             object: nil,
                                             distributed: true)
        }

        let notificationCenter: NotificationCenter = NotificationCenter.default
        var observer: NSObjectProtocol!
        observer = notificationCenter.addObserver(forName: .alreadyAccounts, object: nil, queue: nil, using: { notification in
            let existAccount = self.twitterAccounts.existAccount
            self.updateCurrentAccount(to: existAccount)

            if existAccount {
                let menu = NSMenu()
                for userID in self.twitterAccounts.listKeys {
                    let twitterAccount = self.twitterAccounts.list[userID]
                    let menuItem = NSMenuItem()
                    menuItem.title = (twitterAccount?.name)!
                    menuItem.action = #selector(self.tweetBySelectingAccount(_:))
                    menu.addItem(menuItem)
                }
                self.tweetMenu.submenu = menu
            }

            notificationCenter.removeObserver(observer)
        })
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

        self.tweetNowPlaying(by: self.twitterAccounts.current)
    }

    @IBAction func showPreferences(_ sender: Any) {
        PreferencesWindowController.shared.showWindow(sender)
    }

    @IBAction func tweetByCurrentAccount(_ sender: NSMenuItem) {
        self.tweetNowPlaying(by: self.twitterAccounts.current)
    }

    @objc func tweetBySelectingAccount(_ sender: NSMenuItem) {
        let account = self.twitterAccounts.list[sender.title]
        self.tweetNowPlaying(by: account)
    }

    func tweetNowPlaying(by twitterAccounts: TwitterAccount?) {
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
        } catch NPTError.NotExistTrack {
            let alert = NSAlert(message: "Not exist music.",
                                style: .informational)
            alert.runModal()
        } catch let error {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }

    func postTweet(with twitterAccount: TwitterAccount?, failure: Swifter.FailureHandler? = nil) throws {
        if !self.twitterAccounts.existAccount {
            throw NPTError.NotLogin
        }

        self.playerInfo.updateTrack()

        if !self.playerInfo.existTrack {
            throw NPTError.NotExistTrack
        }

        let tweetText = self.createTweetText()

        if self.userDefaults.bool(forKey: "TweetWithImage") {
            twitterAccount?.tweet(text: tweetText, with: self.playerInfo.artwork, failure: failure)
        } else {
            twitterAccount?.tweet(text: tweetText, failure: failure)
        }
    }

    func createTweetText() -> String {
        var format = self.userDefaults.string(forKey: "TweetFormat")!

        let convertDictionary: [String : String] = [
            "{{Title}}" : self.playerInfo.title!,
            "{{Artist}}" : self.playerInfo.artist!,
            "{{Album}}" : self.playerInfo.album!,
            "{{AlbumArtist}}" : self.playerInfo.albumArtist!,
            "{{BitRate}}" : String(self.playerInfo.bitRate!),
        ]

        for (from,to) in convertDictionary {
            while let range = format.range(of: from) {
                format.replaceSubrange(range, with: to)
            }
        }

        return format
    }

    func updateCurrentAccount(to existAccount: Bool) {
        if existAccount {
            self.currentAccount.title = self.twitterAccounts.current!.name
            self.currentAccount.fetchImage(url: self.twitterAccounts.current!.avaterUrl, rounded: true)
        }

        self.currentAccount.isHidden = !existAccount
        self.currentSeparator.isHidden = !existAccount
    }

}
