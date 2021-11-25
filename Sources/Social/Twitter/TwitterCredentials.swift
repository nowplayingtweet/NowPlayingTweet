/**
 *  TwitterCredentials.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

struct TwitterCredentials: Credentials, Codable,  OAuth1 {

    let apiKey: String
    let apiSecret: String

    let oauthToken: String
    let oauthSecret: String

}
