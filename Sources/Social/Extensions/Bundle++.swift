/**
 *  Bundle++.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

extension Bundle {

    var displayName: String? {
        return self.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? self.object(forInfoDictionaryKey: "CFBundleName") as? String
    }

}
