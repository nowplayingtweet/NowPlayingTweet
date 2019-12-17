/**
 *  AdvancedPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class AdvancedPaneController: NSViewController {

    @IBOutlet weak var useKeyShortcutButton: NSButton!
    @IBOutlet weak var postWithImageButton: NSButton!
    @IBOutlet weak var autoPostButton: NSButton!

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

    private var postWithImage: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "PostWithImage")
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "PostWithImage")
            UserDefaults.standard.synchronize()
        }
    }

    private var autoPost: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "AutoPost")
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "AutoPost")
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
            let notificationCenter: NotificationCenter = NotificationCenter.default
            var observer: NSObjectProtocol!
            observer = notificationCenter.addObserver(forName: .disableAutoPost, object: nil, queue: nil, using: { notification in
                notificationCenter.removeObserver(observer!)

                self.autoPost = false
                self.autoPostButton.set(state: self.autoPost)
            })
        }
    }

}
