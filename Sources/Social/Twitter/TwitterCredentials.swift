/**
 *  TwitterCredentials.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation
import SocialProtocol

struct TwitterCredentials: Credentials, OAuth1, Codable {

    let apiKey: String
    let apiSecret: String

    let oauthToken: String
    let oauthSecret: String

}
