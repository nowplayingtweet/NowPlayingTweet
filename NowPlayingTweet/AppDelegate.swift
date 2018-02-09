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

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    let userDefaults: UserDefaults = UserDefaults.standard

    let twitterAccounts: TwitterAccounts = TwitterAccounts()

    var playerInfo: iTunesPlayerInfo = iTunesPlayerInfo()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        // Defines get URL handler
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(self.handleEvent(_:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
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
            notificationObserver.addObserver(true, self, name: .iTunesPlayerInfo, selector: #selector(AppDelegate.handleNowPlaying(_:)))
        }

        let notificationCenter: NotificationCenter = NotificationCenter.default
        var observer: NSObjectProtocol!
        observer = notificationCenter.addObserver(forName: .alreadyAccounts, object: nil, queue: nil, using: { notification in
            if self.twitterAccounts.existAccount {
                self.currentAccount.title = self.twitterAccounts.current!.name
                self.currentAccount.fetchImage(url: self.twitterAccounts.current!.avaterUrl,
                                               rounded: true)
                self.currentAccount.isHidden = false
                self.currentSeparator.isHidden = false
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

        try! self.postTweet()
    }

    @IBAction func tweetNowPlaying(_ sender: Any) {
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
            try self.postTweet(failure: tweetFailureHandler)
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

    func postTweet(failure: Swifter.FailureHandler? = nil) throws {
        guard self.twitterAccounts.existAccount else {
            throw NPTError.NotLogin
        }

        self.playerInfo.updateTrack()

        if !self.playerInfo.existTrack {
            throw NPTError.NotExistTrack
        }

        let tweetText = self.createTweetText()

        if self.userDefaults.bool(forKey: "TweetWithImage") {
            self.twitterAccounts.current?.tweet(text: tweetText, with: self.playerInfo.artwork, failure: failure)
        } else {
            self.twitterAccounts.current?.tweet(text: tweetText, failure: failure)
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

}
