/**
 *  D14nProviderAccounts.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol D14nProviderAccounts: ProviderAccounts {

    func authorize(base: String, handler: @escaping (Account?, Error?) -> Void)

}

extension D14nProviderAccounts {

    func authorize(handler: @escaping (Account?, Error?) -> Void) {
        self.authorize(base: "", handler: handler)
    }

}
