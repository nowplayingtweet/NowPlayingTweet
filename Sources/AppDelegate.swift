/**
 *  AppDelegate.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import Magnet
import SwifterMac
import KeychainAccess

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, KeyEquivalentsDelegate, NSMenuItemValidation {

    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var currentAccount: NSMenuItem!
    @IBOutlet weak var postMenu: NSMenuItem!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    let userDefaults: UserDefaults = UserDefaults.standard

    let keyEquivalents: GlobalKeyEquivalents = GlobalKeyEquivalents.shared

    let playerInfo: iTunesPlayerInfo = iTunesPlayerInfo()

    override init() {
        super.init()

        // Remove old accounts
        try? Keychain(service: "com.kr-kp.NowPlayingTweet.AccountToken").removeAll()

        let pattern = "^(\(Provider.allCases.map({ String(describing: $0) }).joined(separator: "|")))"
        if let regexp = try? NSRegularExpression(pattern: pattern, options: []) {
            for identifier in self.userDefaults.keyComboIdentifier() {
                if identifier == "Current"
                    || regexp.firstMatch(in: identifier, range: NSRange(identifier.startIndex..., in: identifier)) != nil {
                    continue
                }

                self.userDefaults.removeKeyCombo(forKey: identifier)
            }
        }

        self.userDefaults.removeObject(forKey: "CurrentAccount")

        if let tweetFormat = self.userDefaults.string(forKey: "TweetFormat") {
            self.userDefaults.set(tweetFormat, forKey: "PostFormat")
            self.userDefaults.removeObject(forKey: "TweetFormat")
        }

        if let tweetWithImage = self.userDefaults.object(forKey: "TweetWithImage") {
            self.userDefaults.set(tweetWithImage, forKey: "PostWithImage")
            self.userDefaults.removeObject(forKey: "TweetWithImage")
        }

        if let autoTweet = self.userDefaults.object(forKey: "AutoTweet") {
            self.userDefaults.set(autoTweet, forKey: "AutoPost")
            self.userDefaults.removeObject(forKey: "AutoTweet")
        }

        let defaultSettings: [String : Any] = [
            "PostFormat" : "#NowPlaying {{Title}} by {{Artist}} from {{Album}}",
            "UseKeyShortcut" : false,
            "PostWithImage" : true,
            "AutoPost" : false,
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

            self.updateSocialAccount()
        })

        self.updateSocialAccount()

        if let button = self.statusItem.button {
            button.title = "♫"
        }

        self.statusItem.menu = self.menu

        if self.userDefaults.bool(forKey: "AutoPost") {
            self.manageAutoPost(state: true)
        }

        self.keyEquivalents.set(delegate: self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        self.userDefaults.synchronize()
        HotKeyCenter.shared.unregisterAll()
    }

    @objc func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.identifier == NSUserInterfaceItemIdentifier("PostNowPlaying") {
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

        self.postNowPlaying(by: Accounts.shared.current, auto: true)
    }

    @IBAction private func postByCurrentAccount(_ sender: NSMenuItem) {
        self.postNowPlaying(by: Accounts.shared.current)
    }

    @objc func postBySelectingAccount(_ sender: NSMenuItem) {
        let account = Accounts.shared.sortedAccounts.first(where: { account in
            return "\(type(of: account).provider)_\(account.id)" == sender.identifier?.rawValue
        })
        self.postNowPlaying(by: account)
    }

    func postNowPlaying(by account: Account?, auto: Bool = false) {
        let postFailureHandler: Client.Failure = { error in
            if let err = error as? SwifterError {
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

                let alert = NSAlert(message: "Post failed!",
                                    informative: informative,
                                    style: .warning)
                alert.runModal()

                return
            }

            guard let err = error as? NPTError else {
                let alert = NSAlert(error: error)
                alert.runModal()

                return
            }

            switch err {
            case .NotLogin:
                let title: String = "Not logged in!"
                var informative: String = "Please login with Preferences -> Account."
                if auto {
                    self.manageAutoPost(state: false)
                    informative.append("\n")
                    informative.append("Disable Auto Post.")
                }

                let alert = NSAlert(message: title,
                                    informative: informative,
                                    style: .critical)
                alert.runModal()
            case .NotLaunchediTunes:
                let alert = NSAlert(message: "Not runnning iTunes.",
                                    style: .informational)
                alert.runModal()
            case .NotExistTrack:
                let alert = NSAlert(message: "Not exist music.",
                                style: .informational)
                alert.runModal()
            case .Unknown(let message):
                let alert = NSAlert(message: "Some Error.",
                                    informative: message,
                                    style: .informational)
                alert.runModal()
            }

        }

        self.post(with: account, failure: postFailureHandler)
    }

    private func post(with account: Account?, failure: Client.Failure? = nil) {
        if !Accounts.shared.existsAccounts {
            failure?(NPTError.NotLogin)
            return
        }
        guard let account = account else {
            failure?(NPTError.Unknown("Hasn't account"))
            return
        }

        self.playerInfo.updateTrack()

        if !self.playerInfo.isRunningiTunes {
            failure?(NPTError.NotLaunchediTunes)
            return
        }

        if !self.playerInfo.existTrack {
            failure?(NPTError.NotExistTrack)
            return
        }

        let currentTrack: iTunesPlayerInfo.Track = self.playerInfo.currentTrack!

        let postText = self.createPostText(from: currentTrack)

        if self.userDefaults.bool(forKey: "PostWithImage") {
            Accounts.shared.client(for: account)?.post(text: postText, image: currentTrack.artwork, failure: failure)
        } else {
            Accounts.shared.client(for: account)?.post(text: postText, failure: failure)
        }
    }

    private func createPostText(from track: iTunesPlayerInfo.Track) -> String {
        var format = self.userDefaults.string(forKey: "PostFormat")!

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

    func updateSocialAccount() {
        if AccountPaneController.shared.isViewLoaded {
            AccountPaneController.shared.accountReload()
        }

        self.postMenu.submenu = nil

        if let current = Accounts.shared.current {
            self.currentAccount.title = "\(type(of: current).provider) @\(current.username)"
            self.currentAccount.fetchImage(url: current.avaterUrl, rounded: true)
        } else {
            self.currentAccount.title = "Not Logged in..."
            self.currentAccount.setGuestImage()
        }

        if !Accounts.shared.existsAccounts {
            self.postMenu.isEnabled = false
            return
        }

        self.postMenu.isEnabled = true

        if Accounts.shared.sortedAccounts.count <= 1 {
            return
        }

        let menu = NSMenu()
        for account in Accounts.shared.sortedAccounts {
            let menuItem = NSMenuItem()
            menuItem.title = "\(type(of: account).provider) @\(account.username)"
            menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: "\(type(of: account).provider)_\(account.id)")
            menuItem.action = #selector(AppDelegate.postBySelectingAccount(_:))
            menu.addItem(menuItem)
        }
        self.postMenu.submenu = menu
    }

    func manageAutoPost(state: Bool) {
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
            notificationCenter.post(name: .disableAutoPost, object: nil)
        }
    }

    func postWithCurrent() {
        self.postNowPlaying(by: Accounts.shared.current)
    }

    func post(with id: String, of provider: Provider) {
        self.postNowPlaying(by: Accounts.shared.account(provider, id: id))
    }

}
