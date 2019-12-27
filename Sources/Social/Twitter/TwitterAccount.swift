/**
 *  TwitterAccount.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation
import SocialProtocol

struct TwitterAccount: Account, Equatable {

    static let provider = Provider.Twitter

    public let id: String
    public let name: String
    public let username: String
    public let avaterUrl: URL

}

extension Provider {
    static let Twitter = Provider(rawValue: "Twitter")
}
