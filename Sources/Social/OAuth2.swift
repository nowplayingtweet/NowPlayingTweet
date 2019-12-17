/**
 *  OAuth2.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol OAuth2 {

    var oauthToken: String { get }

}

extension OAuth2 where Self: Credentials {

    static var oauthVersion: OAuth {
        return .Two
    }

}
