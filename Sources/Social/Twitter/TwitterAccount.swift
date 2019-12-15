/**
 *  TwitterAccount.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation
import Magnet

struct TwitterAccount: Account, Equatable {

    static let provider = Provider.Twitter

    public let id: String
    public var name: String
    public var username: String
    public var avaterUrl: URL

    init(id: String, name: String, username: String, avaterUrl: URL) {
        self.id = id
        self.name = name
        self.username = username
        self.avaterUrl = avaterUrl
    }

}
