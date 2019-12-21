/**
 *  MastodonCredentials.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

struct MastodonCredentials: D14nCredentials, OAuth2, Codable {

    let baseURL: URL

    let apiKey: String
    let apiSecret: String

    let oauthToken: String

}
