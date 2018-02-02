/**
 *  AppDelegate.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import SwifterMac
import ScriptingUtilities
import iTunesScripting

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    let userDefaults: UserDefaults = UserDefaults.standard
    
    let twitterAccount: TwitterAccount = TwitterAccount()
    
    var playerInfo: iTunesPlayerInfo?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        // Defines get URL handler
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(self.handleEvent(_:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        let defaultSettings: [String : Any] = [
            "TweetFormat": "#NowPlaying {{Title}} by {{Artist}} from {{Album}}",
            "TweetWithImage": true,
            "AutoTweet": true,
            ]
        self.userDefaults.register(defaults: defaultSettings)

        self.statusItem.title = "NPT"
        self.statusItem.highlightMode = true
        self.statusItem.menu = self.menu

        if self.userDefaults.bool(forKey: "AutoTweet") {
            let notificationObserver: NotificationObserver = NotificationObserver()
            notificationObserver.addObserver(true, self, name: .iTunesPlayerInfo, selector: #selector(AppDelegate.handleNowPlaying(_:)))
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

        self.playerInfo = self.getPlayerInfo()
        self.postTweet()
    }

    func getPlayerInfo() -> iTunesPlayerInfo {
        let iTunes: iTunesApplication = ScriptingUtilities.application(name: "iTunes") as! iTunesApplication
        //let iTunes = ScriptingUtilities.application(bundleIdentifier: "com.apple.iTunes") as! iTunesApplication

        let currentTrack: iTunesTrack = iTunes.currentTrack!

        return iTunesPlayerInfo(currentTrack)
    }

    func postTweet() {
        let tweetText = self.createTweetText()
        if self.userDefaults.bool(forKey: "TweetWithImage") {
            self.twitterAccount.tweet(text: tweetText, with: self.playerInfo?.artwork)
        } else {
            self.twitterAccount.tweet(text: tweetText)
        }
    }

    func createTweetText() -> String {
        var format = self.userDefaults.string(forKey: "TweetFormat")!

        while true {
            if let range = format.range(of: "{{Title}}") {
                format.replaceSubrange(range, with: (self.playerInfo?.title)!)
                continue
            }

            if let range = format.range(of: "{{Artist}}") {
                format.replaceSubrange(range, with: (self.playerInfo?.artist)!)
                continue
            }

            if let range = format.range(of: "{{Album}}") {
                format.replaceSubrange(range, with: (self.playerInfo?.album)!)
                continue
            }

            if let range = format.range(of: "{{AlbumArtist}}") {
                format.replaceSubrange(range, with: (self.playerInfo?.albumArtist)!)
                continue
            }

            if let range = format.range(of: "{{BitRate}}") {
                format.replaceSubrange(range, with: String((self.playerInfo?.bitRate)!))
                continue
            }

            break
        }

        return format
    }

}
