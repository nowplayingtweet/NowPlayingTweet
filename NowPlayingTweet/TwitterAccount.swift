/**
 *  TwitterAccount.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import AppKit
import SwifterMac
import KeychainAccess

struct TwitterAccount {

    var swifter: Swifter

    let userID: String

    let oauthToken: String
    let oauthSecret: String

    let screenName: String
    let avaterUrl: URL

    func tweet(text: String, with artwork: NSImage? = nil, success: Swifter.SuccessHandler? = nil, failure: Swifter.FailureHandler? = nil) {
        if artwork == nil {
            self.swifter.postTweet(status: text, success: success, failure: failure)
            return
        }
        let image = artwork?.toData(from: .jpeg)
        self.swifter.postTweet(status: text, media: image!, success: success, failure: failure)
    }

}
