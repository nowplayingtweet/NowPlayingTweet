/**
 *  Account.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol Account {
    var provider: Provider { get }

    var id: String { get }
    var name: String { get set }
    var screenName: String { get set }
    var avaterUrl: URL { get set }

    var authToken: AuthToken { get }

    init(id: String, name: String, screenName: String, avaterUrl: URL, token: AuthToken)
}
