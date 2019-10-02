/**
 *  Client.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol Client {
    static func authorize(handler: @escaping (Account) -> Void)

    static func revoke(authToken: AuthToken)

    static func verify(authToken: AuthToken, handler: @escaping (Account) -> Void)

    static func post(authToken: AuthToken)
}
