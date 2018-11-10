/**
 *  Provider.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class Provider {

    struct Name: Equatable, Hashable, RawRepresentable {

        static func == (lhs: Provider.Name, rhs: Provider.Name) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

        typealias RawValue = String

        let rawValue: String

        init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        init(rawValue: String) {
            self.init(rawValue)
        }

    }

}


extension Provider.Name {

    static let twitter = Provider.Name("Twitter")

}
