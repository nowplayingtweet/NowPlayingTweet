/**
 *  ProviderAccounts.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation
import SocialProtocol

protocol ProviderAccounts {

    var storage: [String : (Account, Credentials)] { get }

    init(keychainPrefix: String)

    func authorize(handler: @escaping (Account?, Error?) -> Void)

    func revoke(id: String, handler: @escaping (Error?) -> Void)

}
