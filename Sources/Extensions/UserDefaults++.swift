/**
 *  UserDefaults++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import Magnet

extension UserDefaults {

    func keyCombo(forKey key: String) -> KeyCombo? {
        guard let keyEquivalents: [String : Data] = self.dictionary(forKey: "KeyEquivalents") as? [String : Data] else {
            return nil
        }

        var keyCombo: KeyCombo?
        if let keyComboData = keyEquivalents[key] {
            keyCombo = NSKeyedUnarchiver.unarchiveObject(with: keyComboData) as? KeyCombo
        }

        return keyCombo
    }

    func keyComboIdentifier() -> [String] {
        var identifiers: [String] = self.dictionary(forKey: "KeyEquivalents")?.map { $0.key } ?? []
        identifiers = identifiers.sorted()

        guard let index = identifiers.index(of: "Current") else {
            return identifiers
        }

        identifiers.remove(at: index)

        var keys = ["Current"]
        for identifier in identifiers {
            keys.append(identifier)
        }

        return keys
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

    func removeKeyCombo(forKey key: String) {
        var keyEquivalents = self.dictionary(forKey: "KeyEquivalents") ?? [:]
        keyEquivalents.removeValue(forKey: key)
        self.set(keyEquivalents, forKey: "KeyEquivalents")
    }

}
