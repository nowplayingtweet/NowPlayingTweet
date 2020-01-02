/**
 *  UserDefaults++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import Magnet
import SocialProtocol

extension UserDefaults {

    func keyComboIdentifier() -> [String] {
        var identifiers: [String] = self.dictionary(forKey: "KeyEquivalents")?.map { $0.key } ?? []
        identifiers = identifiers.sorted()

        guard let index = identifiers.firstIndex(of: "Current") else {
            return identifiers
        }

        identifiers.remove(at: index)
        identifiers.insert("Current", at: 0)

        return identifiers
    }

    func keyCombo(forKey key: String) -> KeyCombo? {
        guard let keyEquivalents = self.dictionary(forKey: "KeyEquivalents") as? [String : Data] else {
            return nil
        }

        var keyCombo: KeyCombo?
        if let keyComboData = keyEquivalents[key] {
            keyCombo = NSKeyedUnarchiver.unarchiveObject(with: keyComboData) as? KeyCombo
        }

        return keyCombo
    }

    func provider(forKey key: String) -> Provider {
        return Provider(rawValue: self.string(forKey: key) ?? "")
    }

    func accountSetting(forKey key: String) -> [String : Any] {
        guard let settings = UserDefaults.standard.dictionary(forKey: "AccountSettings") as? [String : [String : Any]]
            , let setting = settings[key] else {
            return [
                "Visibility": "Default",
                "ContentWarning": [
                    "Enabled": false,
                    "SpoilerText": "",
                ],
                "SensitiveImage": false,
            ]
        }

        return setting
    }

    func set(_ keyCombo: KeyCombo?, forKey key: String) {
        var keyEquivalents = self.dictionary(forKey: "KeyEquivalents") ?? [:]

        var keyComboData: Data?
        if let keyCombo = keyCombo {
            keyComboData = NSKeyedArchiver.archivedData(withRootObject: keyCombo) as Data?
        }

        keyEquivalents[key] = keyComboData
        self.set(keyEquivalents, forKey: "KeyEquivalents")
    }

    func set(_ provider: Provider, forKey key: String) {
        self.set(String(describing: provider), forKey: key)
    }

    func setAccountSetting(_ setting: [String : Any], forKey key: String) {
        var settings = UserDefaults.standard.dictionary(forKey: "AccountSettings") as? [String : [String : Any]] ?? [:]
        settings[key] = setting

        self.set(settings, forKey: "AccountSettings")
    }

    func removeKeyCombo(forKey key: String) {
        var keyEquivalents = self.dictionary(forKey: "KeyEquivalents") ?? [:]
        keyEquivalents.removeValue(forKey: key)
        self.set(keyEquivalents, forKey: "KeyEquivalents")
    }

    func removeProvider(forKey key: String) {
        self.removeObject(forKey: key)
    }

}
