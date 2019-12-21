/**
 *  D14nAccount.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol D14nAccount: Account {

    var domain: String { get }

}

extension D14nAccount {

    var keychainID: String {
        return "\(self.domain)_\(self.id)"
    }

    func isEqual(_ account: Account?) -> Bool {
        guard let account = account
            , let d14nAccount = account as? D14nAccount else {
            return false
        }

        return type(of: self).provider == type(of: account).provider
            && self.id == account.id
            && self.domain == d14nAccount.domain
    }

}
