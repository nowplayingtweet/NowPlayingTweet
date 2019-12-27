/**
 *  Provider++.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Cocoa
import SocialProtocol

extension Provider {

    var icon: NSImage? {
        switch self {
        case .Twitter:
            return NSImage(named: "Twitter Icon")
        case .Mastodon:
            return NSImage(named: "Mastodon Icon")
        default:
            return nil
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
        default:
            return nil
        }
    }

    var accounts: ProviderAccounts.Type? {
        switch self {
        case .Twitter:
            return TwitterAccounts.self
        case .Mastodon:
            return MastodonAccounts.self
        default:
            return nil
        }
    }

}

extension Provider {

    static var allCases: [Provider] {
        return [
            .Twitter,
            .Mastodon,
        ]
    }

}
