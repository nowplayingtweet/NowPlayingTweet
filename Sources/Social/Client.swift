/**
 *  Client.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol Client {
    static func authorize(handler: @escaping (Client) -> Void)

    var credentials: Credentials { get }

    init(credentials: Credentials)

    func revoke(handler: @escaping () -> Void)

    func verify(handler: @escaping (Account) -> Void)

    func post(text: String, handler: @escaping () -> Void)

    func post(text: String, image: Data, handler: @escaping () -> Void)
}
