/**
 *  MastodonAccount.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

struct MastodonAccount: D14nAccount, Equatable {

    static let provider = Provider.Mastodon

    public let id: String
    public let domain: String
    public let name: String
    public let username: String
    public let avaterUrl: URL

}
