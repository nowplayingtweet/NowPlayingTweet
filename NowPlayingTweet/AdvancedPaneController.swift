/**
 *  AdvancedPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import LaunchAtLogin

class AdvancedPaneController: NSViewController {

    @IBOutlet weak var launchAtLogin: NSButton!
    @IBOutlet weak var useKeyShortcut: NSButton!
    @IBOutlet weak var tweetWithImage: NSButton!
    @IBOutlet weak var autoTweet: NSButton!

    private let appDelegate: AppDelegate = NSApplication.shared.delegate as! AppDelegate

    private let userDefaults: UserDefaults = UserDefaults.standard

    private let keyEquivalents: GlobalKeyEquivalents = GlobalKeyEquivalents.shared

    static let shared: AdvancedPaneController = {
        let storyboard = NSStoryboard(name: .main, bundle: .main)
        let windowController = storyboard.instantiateController(withIdentifier: .advancedPaneController)
        return windowController as! AdvancedPaneController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.
        self.launchAtLogin.set(state: self.userDefaults.bool(forKey: "LaunchAtLogin"))
        self.useKeyShortcut.set(state: self.userDefaults.bool(forKey: "UseKeyShortcut"))
        self.tweetWithImage.set(state: self.userDefaults.bool(forKey: "TweetWithImage"))
        self.autoTweet.set(state: self.userDefaults.bool(forKey: "AutoTweet"))

        self.addDisableAutoTweetObserver(state: self.userDefaults.bool(forKey: "AutoTweet"))
    }

    @IBAction private func switchSetting(_ sender: NSButton) {
        let identifier: String = (sender.identifier?.rawValue)!
        let state = sender.state.toBool()

        switch identifier {
        case "LaunchAtLogin":
            LaunchAtLogin.isEnabled = state
        case "UseKeyShortcut":
            self.keyEquivalents.isEnabled = state
        case "AutoTweet":
            self.appDelegate.manageAutoTweet(state: state)
            self.addDisableAutoTweetObserver(state: state)
        default:
            break
        }
        self.userDefaults.set(state, forKey: identifier)
        self.userDefaults.synchronize()
    }

    private func addDisableAutoTweetObserver(state: Bool) {
        if state {
            let notificationCenter: NotificationCenter = NotificationCenter.default
            var observer: NSObjectProtocol!
            observer = notificationCenter.addObserver(forName: .disableAutoTweet, object: nil, queue: nil, using: { notification in
                self.userDefaults.set(false, forKey: "AutoTweet")
                self.userDefaults.synchronize()
                self.autoTweet.set(state: self.userDefaults.bool(forKey: "AutoTweet"))
                notificationCenter.removeObserver(observer)
            })
        }
    }

}
