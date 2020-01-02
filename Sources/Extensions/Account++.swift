/**
 *  Account++.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Cocoa
import SocialProtocol

extension Account {

    var keychainID: String {
        return self.id
    }

}

extension D14nAccount {

    var keychainID: String {
        return "\(self.domain)_\(self.id)"
    }

}
