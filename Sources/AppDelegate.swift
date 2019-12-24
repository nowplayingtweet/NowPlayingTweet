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

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    lazy var playerInfo = iTunesPlayerInfo()

    private let keyEquivalents = GlobalKeyEquivalents.shared

    private let userDefaults = UserDefaults.standard

    private let accounts = Accounts.shared

    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var currentAccount: NSMenuItem!
    @IBOutlet weak var postMenu: NSMenuItem!

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
        var token: NSObjectProtocol?
        token = NotificationCenter.default.addObserver(forName: .alreadyAccounts, object: nil, queue: nil, using: { notification in
            defer {
                NotificationCenter.default.removeObserver(token!)
            }

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
            return self.accounts.current != nil
        }

        return true
    }

    @objc func handleGetURLEvent(_ event: NSAppleEventDescriptor, with _: NSAppleEventDescriptor) {
        for provider in self.accounts.availableProviders {
            guard let client = provider.client as? AuthorizeByCallback.Type else {
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

        self.postNowPlaying(by: self.accounts.current, auto: true)
    }

    @IBAction private func postByCurrentAccount(_ sender: NSMenuItem) {
        self.postNowPlaying(by: self.accounts.current)
    }

    @objc func postBySelectingAccount(_ sender: NSMenuItem) {
        let account = self.accounts.sortedAccounts.first(where: { account in
            return "\(type(of: account).provider)_\(account.keychainID)" == sender.identifier?.rawValue
        })
        self.postNowPlaying(by: account)
    }

    func postNowPlaying(by account: Account?, auto: Bool = false) {
        let postFailureHandler: Client.Failure = { error in
            switch error {
            case let err as SwifterError:
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
            case NPTError.NotLogin:
                let title: String = "Not logged in!"
                var informative: String = "Please login with \"Preferences…\" -> \"Account\"."
                if auto {
                    self.manageAutoPost(state: false)
                    informative.append("\n")
                    informative.append("Disable Auto Post.")
                }

                let alert = NSAlert(message: title,
                                    informative: informative,
                                    style: .critical)
                alert.runModal()
            case NPTError.NotLaunchediTunes:
                let alert = NSAlert(message: "Not runnning iTunes.",
                                    style: .informational)
                alert.runModal()
            case NPTError.HasNotPermission:
                let alert = NSAlert(message: "Has not permission for iTunes.",
                                    informative: "Please turn on iTunes from System Preferences.app\n\"Security & Privacy\" -> \"Privacy\" -> \"Automation\".",
                                    style: .warning)
                alert.runModal()
            case NPTError.NotExistsTrack:
                let alert = NSAlert(message: "Not exists music.",
                                    style: .informational)
                alert.runModal()
            case NPTError.Unknown(let message):
                let alert = NSAlert(message: "Some Error.",
                                    informative: message,
                                    style: .warning)
                alert.runModal()
            default:
                let alert = NSAlert(error: error)
                alert.runModal()
            }
        }

        self.post(with: account, failure: postFailureHandler)
    }

    private func post(with account: Account?, failure: Client.Failure? = nil) {
        if !self.accounts.existsAccounts {
            failure?(NPTError.NotLogin)
            return
        }
        guard let account = account else {
            failure?(NPTError.Unknown("Hasn't account"))
            return
        }

        if !self.playerInfo.isRunning {
            failure?(NPTError.NotLaunchediTunes)
            return
        }

        if !self.playerInfo.hasPermission {
            failure?(NPTError.HasNotPermission)
            return
        }

        if !self.playerInfo.existsTrack {
            failure?(NPTError.NotExistsTrack)
            return
        }

        let currentTrack: iTunesPlayerInfo.Track = self.playerInfo.currentTrack!

        let postText = self.createPostText(from: currentTrack)
        let artwork = self.userDefaults.bool(forKey: "PostWithImage") ? currentTrack.artwork : nil

        self.accounts.post(with: account, text: postText, image: artwork, success: nil, failure: failure)
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

        if let current = self.accounts.current as? D14nAccount {
             self.currentAccount.title = "@\(current.username)@\(current.domain)"
             self.currentAccount.fetchImage(url: current.avaterUrl, rounded: true)
        } else if let current = self.accounts.current {
            self.currentAccount.title = "\(type(of: current).provider) @\(current.username)"
            self.currentAccount.fetchImage(url: current.avaterUrl, rounded: true)
        } else {
            self.currentAccount.title = "Not Logged in..."
            self.currentAccount.setGuestImage()
        }

        if self.accounts.sortedAccounts.count <= 1 {
            return
        }

        let menu = NSMenu()
        for account in self.accounts.sortedAccounts {
            let menuItem = NSMenuItem()
            if let account = account as? D14nAccount {
                menuItem.title = "\(account.domain) @\(account.username)"
            } else {
                menuItem.title = "\(type(of: account).provider) @\(account.username)"
            }
            menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: "\(type(of: account).provider)_\(account.keychainID)")
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
            NotificationCenter.default.post(name: .disableAutoPost, object: nil)
        }
    }

    func postWithCurrent() {
        self.postNowPlaying(by: self.accounts.current)
    }

    func post(with id: String, of provider: Provider) {
        self.postNowPlaying(by: self.accounts.sortedAccounts.first { account in
            return type(of: account).provider == provider
                && account.keychainID == id
        })
    }

}
