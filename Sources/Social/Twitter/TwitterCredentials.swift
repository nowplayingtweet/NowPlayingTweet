/**
 *  TwitterCredentials.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

struct TwitterCredentials: Credentials, Codable,  OAuth1 {

    static let apiKey: String = "uH6FFqSPBi1ZG80I6taO5xt24"
    static let apiSecret: String = "0gIbzrGYW6CU2W3DoehwuLQz8SXojr8v5z5I2DaBPjm9kHbt16"

    var oauthToken: String
    var oauthSecret: String

}
