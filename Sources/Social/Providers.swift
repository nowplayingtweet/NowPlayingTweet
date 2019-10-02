/**
 *  Providers.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol Providers {}

struct Provider: RawRepresentable {
    typealias RawValue = String

    let rawValue: String
}

extension Provider: Providers {}

extension Providers {
    static var Unknown: Provider {
        return Provider(rawValue: "unknown")
    }
}
