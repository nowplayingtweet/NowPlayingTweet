/**
 *  Provider.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Cocoa

enum Provider: String, CaseIterable {

    case Twitter

}

extension Provider {

    var accounts: ProviderAccounts.Type {
        switch self {
            case .Twitter: return TwitterAccounts.self
        }
    }

    var client: Client.Type {
        switch self {
            case .Twitter: return TwitterClient.self
        }
    }

    var credentials: Credentials.Type {
        switch self {
            case .Twitter: return TwitterCredentials.self
        }
    }

    var logo: NSImage? {
        switch self {
            case .Twitter: return NSImage(named: "Twitter Logo")
        }
    }

    var brand: NSImage? {
        switch self {
            case .Twitter: return nil
        }
    }

}
