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
    var name: String { get }
    var screenName: String { get }
    var avaterUrl: URL { get }

    var client: Client? { get }
}
