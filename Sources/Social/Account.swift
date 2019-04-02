/**
 *  Account.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol Account {
    var provider: Provider { get }

    var name: String { get }
    var screenName: String { get }
    var avaterUrl: URL { get }
}
