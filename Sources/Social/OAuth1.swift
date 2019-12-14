/**
 *  OAuth1.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol OAuth1 {
    static var apiKey: String { get }
    static var apiSecret: String { get }

    var oauthToken: String { get }
    var oauthSecret: String { get }
}

extension OAuth1 where Self: Credentials {
    static var oauthVersion: OAuth {
        return .One
    }
}
