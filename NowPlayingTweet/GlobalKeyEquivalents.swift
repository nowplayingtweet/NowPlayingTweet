/**
 *  GlobalKeyEquivalents.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import Carbon
import Magnet

class GlobalKeyEquivalents: NSObject {

    static let shared: GlobalKeyEquivalents = GlobalKeyEquivalents()

    let userDefaults: UserDefaults = UserDefaults.standard

    var isEnabled: Bool {
        return self.userDefaults.bool(forKey: "UseKeyShortcut")
    }

    let keyCombo: KeyCombo = KeyCombo(keyCode: kVK_ANSI_I, cocoaModifiers: [.control, .option])!

    let hotKeyCenter: HotKeyCenter = HotKeyCenter.shared

    private weak var delegate: KeyEquivalentsDelegate?

    private override init() {
        super.init()

        if !self.isEnabled  {
            return
        }

        let hotKey: HotKey = HotKey(identifier: "TweetWithCurrent", keyCombo: self.keyCombo, target: self, action: #selector(self.handleHotKey))

        if !self.hotKeyCenter.register(with: hotKey) {
            self.unregister()
        }
    }

    func set(delegate: KeyEquivalentsDelegate) {
        self.delegate = delegate
    }

    func register() {
        self.userDefaults.set(true, forKey: "UseKeyShortcut")
        self.userDefaults.synchronize()

        let hotKey: HotKey = HotKey(identifier: "TweetWithCurrent", keyCombo: self.keyCombo, target: self, action: #selector(self.handleHotKey))

        if !self.hotKeyCenter.register(with: hotKey) {
            self.unregister()
        }
    }

    func unregister() {
        self.userDefaults.set(false, forKey: "UseKeyShortcut")
        self.userDefaults.synchronize()

        self.hotKeyCenter.unregisterHotKey(with: "TweetWithCurrent")
    }

    @objc private func handleHotKey() {
        print("handle hotkey")
        self.delegate?.tweetWithCurrent()
    }

}
