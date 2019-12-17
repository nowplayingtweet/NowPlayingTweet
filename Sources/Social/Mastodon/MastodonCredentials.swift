/**
 *  MastodonCredentials.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

struct MastodonCredentials: Credentials, Codable, OAuth2 {

    let apiKey: String
    let apiSecret: String

    let oauthToken: String

}
