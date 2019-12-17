/**
 *  Provider++.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Cocoa

extension Provider {

    var accounts: ProviderAccounts.Type? {
        switch self {
        case .Twitter:
            return TwitterAccounts.self
        default:
            return nil
        }
    }

    var client: Client.Type? {
        switch self {
        case .Twitter:
            return TwitterClient.self
        default:
            return nil
        }
    }

    var credentials: Credentials.Type? {
        switch self {
        case .Twitter:
            return TwitterCredentials.self
        default:
            return nil
        }
    }

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

    var clientKey: (String, String)? {
        switch self {
        case .Twitter:
            let apiKey: String = "uH6FFqSPBi1ZG80I6taO5xt24"
            let apiSecret: String = "0gIbzrGYW6CU2W3DoehwuLQz8SXojr8v5z5I2DaBPjm9kHbt16"
            return (apiKey, apiSecret)
        default:
            return nil
        }
    }

}
