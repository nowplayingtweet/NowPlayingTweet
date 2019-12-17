/**
 *  OAuth1.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol OAuth1 {

    var oauthToken: String { get }
    var oauthSecret: String { get }

}

extension OAuth1 where Self: Credentials {

    static var oauthVersion: OAuth {
        return .One
    }

}
