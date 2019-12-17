/**
 *  ProviderAccounts.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol ProviderAccounts {

    var storage: [String : (Account, Credentials)] { get }

    init(keychainPrefix: String)

    func saveToKeychain(account: Account, credentials: Credentials)

    func deleteFromKeychain(id: String)

}
