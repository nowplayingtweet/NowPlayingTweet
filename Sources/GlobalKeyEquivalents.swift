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

    private let userDefaults: UserDefaults = UserDefaults.standard

    var isEnabled: Bool {
        get {
            return self.userDefaults.bool(forKey: "UseKeyShortcut")
        }
        set {
            if newValue {
                self.start()
            } else {
                self.hotKeyCenter.unregisterAll()
            }
        }
    }

    private let hotKeyCenter: HotKeyCenter = HotKeyCenter.shared

    private weak var delegate: KeyEquivalentsDelegate?

    private override init() {
        super.init()

        self.start()
    }

    func set(delegate: KeyEquivalentsDelegate) {
        self.delegate = delegate
    }

    private func start() {
        if !self.isEnabled  {
            return
        }

        for identifier in self.userDefaults.keyComboIdentifier() {
            if let keyCombo: KeyCombo = self.userDefaults.keyCombo(forKey: identifier) {
                self.register(identifier, keyCombo: keyCombo)
            }
        }
    }

    func register(_ identifier: String, keyCombo: KeyCombo) {
        self.userDefaults.set(keyCombo, forKey: identifier)
        self.userDefaults.synchronize()

        if !self.isEnabled  {
            return
        }

        let hotKey: HotKey = HotKey(identifier: identifier, keyCombo: keyCombo, handler: handleHotKeyEvent)
        hotKey.register()
    }

    func unregister(_ identifier: String) {
        self.userDefaults.removeKeyCombo(forKey: identifier)
        self.userDefaults.synchronize()

        self.hotKeyCenter.unregisterHotKey(with: identifier)
    }

    private func handleHotKeyEvent(_ hotKey: HotKey) {
        let id = hotKey.identifier

        if id == "Current" {
            self.delegate?.tweetWithCurrent()
            return
        }

        self.delegate?.tweet(with: id, of: .Twitter)
    }

}
