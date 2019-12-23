/**
 *  AdvancedPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class AdvancedPaneController: NSViewController {

    static let shared: AdvancedPaneController = {
        let windowController = NSStoryboard.main!.instantiateController(withIdentifier: .advancedPaneController)
        return windowController as! AdvancedPaneController
    }()

    private let appDelegate = NSApplication.shared.delegate as! AppDelegate

    private let userDefaults = UserDefaults.standard

    private let keyEquivalents: GlobalKeyEquivalents = GlobalKeyEquivalents.shared

    @IBOutlet weak var useKeyShortcutButton: NSButton!
    @IBOutlet weak var postWithImageButton: NSButton!
    @IBOutlet weak var autoPostButton: NSButton!

    private var useKeyShortcut: Bool {
        get {
            return self.userDefaults.bool(forKey: "UseKeyShortcut")
        }
        set(newValue) {
            self.userDefaults.set(newValue, forKey: "UseKeyShortcut")
        }
    }

    private var postWithImage: Bool {
        get {
            return self.userDefaults.bool(forKey: "PostWithImage")
        }
        set(newValue) {
            self.userDefaults.set(newValue, forKey: "PostWithImage")
        }
    }

    private var autoPost: Bool {
        get {
            return self.userDefaults.bool(forKey: "AutoPost")
        }
        set(newValue) {
            self.userDefaults.set(newValue, forKey: "AutoPost")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.
        self.useKeyShortcutButton.set(state: self.useKeyShortcut)
        self.postWithImageButton.set(state: self.postWithImage)
        self.autoPostButton.set(state: self.autoPost)

        self.addDisableAutoPostObserver(state: self.autoPost)
    }

    @IBAction private func switchSetting(_ sender: NSButton) {
        guard let identifier = sender.identifier?.rawValue else { return }
        let state = sender.state.toBool()

        switch identifier {
          case "UseKeyShortcut":
            self.useKeyShortcut = state
            self.keyEquivalents.isEnabled = state
          case "PostWithImage":
            self.postWithImage = state
          case "AutoPost":
            self.addDisableAutoPostObserver(state: state)
            self.appDelegate.manageAutoPost(state: state)
          default:
            break
        }
    }

    private func addDisableAutoPostObserver(state: Bool) {
        if state {
            var token: NSObjectProtocol?
            token = NotificationCenter.default.addObserver(forName: .disableAutoPost, object: nil, queue: nil, using: { notification in
                defer {
                    NotificationCenter.default.removeObserver(token!)
                }

                self.autoPost = false
                self.autoPostButton.set(state: self.autoPost)
            })
        }
    }

}
