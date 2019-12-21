/**
 *  Provider++.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Cocoa

extension Provider {

    var icon: NSImage? {
        switch self {
        case .Twitter:
            return NSImage(named: "Twitter Icon")
        case .Mastodon:
            return NSImage(named: "Mastodon Icon")
        }
    }

    var logo: NSImage? {
        switch self {
        case .Mastodon:
            return NSImage(named: "Mastodon Logo")
        default:
            return nil
        }
    }

    var client: Client.Type? {
        switch self {
        case .Twitter:
            return TwitterClient.self
        case .Mastodon:
            return MastodonClient.self
        }
    }

    var accounts: ProviderAccounts.Type? {
        switch self {
        case .Twitter:
            return TwitterAccounts.self
        case .Mastodon:
            return MastodonAccounts.self
        }
    }

}
