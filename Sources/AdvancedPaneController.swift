/**
 *  AdvancedPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class AdvancedPaneController: NSViewController {

    @IBOutlet weak var useKeyShortcutButton: NSButton!
    @IBOutlet weak var tweetWithImageButton: NSButton!
    @IBOutlet weak var autoTweetButton: NSButton!

    private let appDelegate: AppDelegate = NSApplication.shared.delegate as! AppDelegate

    private var useKeyShortcut: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "UseKeyShortcut")
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "UseKeyShortcut")
            UserDefaults.standard.synchronize()
        }
    }

    private var tweetWithImage: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "TweetWithImage")
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "TweetWithImage")
            UserDefaults.standard.synchronize()
        }
    }

    private var autoTweet: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "AutoTweet")
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "AutoTweet")
            UserDefaults.standard.synchronize()
        }
    }

    private let keyEquivalents: GlobalKeyEquivalents = GlobalKeyEquivalents.shared

    static let shared: AdvancedPaneController = {
        let windowController = NSStoryboard.main!.instantiateController(withIdentifier: .advancedPaneController)
        return windowController as! AdvancedPaneController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.
        self.useKeyShortcutButton.set(state: self.useKeyShortcut)
        self.tweetWithImageButton.set(state: self.tweetWithImage)
        self.autoTweetButton.set(state: self.autoTweet)

        self.addDisableAutoTweetObserver(state: self.autoTweet)
    }

    @IBAction private func switchSetting(_ sender: NSButton) {
        guard let identifier: String = sender.identifier?.rawValue else { return }
        let state = sender.state.toBool()

        switch identifier {
          case "UseKeyShortcut":
            self.useKeyShortcut = state
            self.keyEquivalents.isEnabled = state
          case "TweetWithImage":
            self.tweetWithImage = state
          case "AutoTweet":
            self.addDisableAutoTweetObserver(state: state)
            self.appDelegate.manageAutoTweet(state: state)
          default:
            break
        }
    }

    private func addDisableAutoTweetObserver(state: Bool) {
        if state {
            let notificationCenter: NotificationCenter = NotificationCenter.default
            var observer: NSObjectProtocol!
            observer = notificationCenter.addObserver(forName: .disableAutoTweet, object: nil, queue: nil, using: { notification in
                notificationCenter.removeObserver(observer!)

                self.autoTweet = false
                self.autoTweetButton.set(state: self.autoTweet)
            })
        }
    }

}
