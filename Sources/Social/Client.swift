/**
 *  SocialClient.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol Client {
    static func login(_: @escaping (Account) -> Void)
    func update(_: @escaping (String, String, URL) -> Void)
}
