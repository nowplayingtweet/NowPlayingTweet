/**
 *  AppDelegate.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import Magnet
import SwifterMac

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, KeyEquivalentsDelegate, NSMenuItemValidation {

    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var currentAccount: NSMenuItem!
    @IBOutlet weak var tweetMenu: NSMenuItem!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    let userDefaults: UserDefaults = UserDefaults.standard

    let keyEquivalents: GlobalKeyEquivalents = GlobalKeyEquivalents.shared

    let playerInfo: iTunesPlayerInfo = iTunesPlayerInfo()

    override init() {
        super.init()

        let defaultSettings: [String : Any] = [
            "TweetFormat" : "#NowPlaying {{Title}} by {{Artist}} from {{Album}}",
            "UseKeyShortcut" : false,
            "TweetWithImage" : true,
            "AutoTweet" : false,
            ]
        self.userDefaults.register(defaults: defaultSettings)
    }

    func applicationWillFinishLaunching(_ aNotification: Notification) {
        // Handle get url event
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(AppDelegate.handleGetURLEvent(_:with:)),
                                                     forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let notificationCenter: NotificationCenter = NotificationCenter.default
        var observer: NSObjectProtocol!
        observer = notificationCenter.addObserver(forName: .alreadyAccounts, object: nil, queue: nil, using: { notification in
            notificationCenter.removeObserver(observer!)

            self.updateTwitterAccount()
        })

        self.updateTwitterAccount()

        if let button = self.statusItem.button {
            button.title = "♫"
        }

        self.statusItem.menu = self.menu

        if self.userDefaults.bool(forKey: "AutoTweet") {
            self.manageAutoTweet(state: true)
        }

        self.keyEquivalents.set(delegate: self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        HotKeyCenter.shared.unregisterAll()
    }

    @objc func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.identifier == NSUserInterfaceItemIdentifier("TweetNowPlaying") {
            return Accounts.shared.existsAccounts
        }

        return true
    }

    @objc func handleGetURLEvent(_ event: NSAppleEventDescriptor, with _: NSAppleEventDescriptor) {
        for provider in Provider.allCases {
            guard let client = provider.client as? CallbackHandler.Type else {
                continue
            }

            client.handleCallback(event)
        }
    }

    @objc func handleNowPlaying(_ notification: Notification) {
        let musicInfo: Dictionary = notification.userInfo!
        if (musicInfo["Player State"]! as! String != "Playing") {
            return
        }

        self.tweetNowPlaying(by: Accounts.shared.current, auto: true)
    }

    @IBAction private func tweetByCurrentAccount(_ sender: NSMenuItem) {
        self.tweetNowPlaying(by: Accounts.shared.current)
    }

    @objc func tweetBySelectingAccount(_ sender: NSMenuItem) {
        let account = Accounts.shared.sortedAccounts.first(where: { account in
            return "\(type(of: account).provider)-\(account.id)" == sender.identifier?.rawValue
        })
        self.tweetNowPlaying(by: account)
    }

    func tweetNowPlaying(by account: Account?, auto: Bool = false) {
        let tweetFailureHandler: Swifter.FailureHandler = { error in
            let err = error as! SwifterError

            let errMsg = err.message.components(separatedBy: ", ")
            let errRes = errMsg[1].components(separatedBy: ": ")

            let resData = errRes[1].data(using: .utf8, allowLossyConversion: false)!
            let jsonData = try! JSONSerialization.jsonObject(with: resData, options: .mutableContainers)
            let json = JSON(jsonData)

            let jsonErrors: [JSON] = json.object!["errors"]!.array!

            var informative: String = ""
            for jsonError in jsonErrors {
                informative.append(jsonError.object!["message"]!.string!)
                informative.append("\n")
            }

            let alert = NSAlert(message: "Tweet failed!",
                                informative: informative,
                                style: .warning)
            alert.runModal()
        }

        do {
            try self.postTweet(with: account, failure: tweetFailureHandler)
        } catch NPTError.NotLogin {
            let title: String = "Not logged in!"
            var informative: String = "Please login with Preferences -> Account."
            if auto {
                self.manageAutoTweet(state: false)
                informative.append("\n")
                informative.append("Disable Auto Tweet.")
            }

            let alert = NSAlert(message: title,
                                informative: informative,
                                style: .critical)
            alert.runModal()
        } catch NPTError.NotLaunchediTunes {
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

    private func postTweet(with account: Account?, failure: Swifter.FailureHandler? = nil) throws {
        if !Accounts.shared.existsAccounts {
            throw NPTError.NotLogin
        }
        guard let account = account else {
            throw NPTError.Unknown("Hasn't account")
        }

        self.playerInfo.updateTrack()

        if !self.playerInfo.isRunningiTunes {
            throw NPTError.NotLaunchediTunes
        }

        if !self.playerInfo.existTrack {
            throw NPTError.NotExistTrack
        }

        let currentTrack: iTunesPlayerInfo.Track = self.playerInfo.currentTrack!

        let tweetText = self.createTweetText(from: currentTrack)

        if self.userDefaults.bool(forKey: "TweetWithImage") {
            Accounts.shared.tweet(account: account, text: tweetText, with: currentTrack.artwork, failure: failure)
        } else {
            Accounts.shared.tweet(account: account, text: tweetText, failure: failure)
        }
    }

    private func createTweetText(from track: iTunesPlayerInfo.Track) -> String {
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
        self.tweetMenu.submenu = nil

        guard let current = Accounts.shared.current else {
            self.currentAccount.title = "Not Logged in..."
            self.currentAccount.setGuestImage()
            self.tweetMenu.isEnabled = false
            return
        }

        self.currentAccount.title = "\(type(of: current).provider) @\(current.username)"
        self.currentAccount.fetchImage(url: current.avaterUrl, rounded: true)
        self.tweetMenu.isEnabled = true

        if Accounts.shared.sortedAccounts.count <= 1 {
            return
        }

        let menu = NSMenu()
        for account in Accounts.shared.sortedAccounts {
            let menuItem = NSMenuItem()
            menuItem.title = "\(type(of: account).provider) @\(account.username)"
            menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: "\(type(of: account).provider)-\(account.id)")
            menuItem.action = #selector(AppDelegate.tweetBySelectingAccount(_:))
            menu.addItem(menuItem)
        }
        self.tweetMenu.submenu = menu
    }

    func manageAutoTweet(state: Bool) {
        let notificationObserver: NotificationObserver = NotificationObserver()
        if state {
            notificationObserver.addObserver(self,
                                             name: .iTunesPlayerInfo,
                                             selector: #selector(AppDelegate.handleNowPlaying(_:)),
                                             object: nil,
                                             distributed: true)
        } else {
            notificationObserver.removeObserver(self,
                                                name: .iTunesPlayerInfo,
                                                object: nil,
                                                distributed: true)
            let notificationCenter: NotificationCenter = NotificationCenter.default
            notificationCenter.post(name: .disableAutoTweet, object: nil)
        }
    }

    func tweetWithCurrent() {
        self.tweetNowPlaying(by: Accounts.shared.current)
    }

    func tweet(with userID: String) {
        self.tweetNowPlaying(by: Accounts.shared.account(userID: userID))
    }

}
