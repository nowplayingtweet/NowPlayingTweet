/**
 *  TwitterClient.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import SwifterMac

class TwitterClient: SocialClient {

    let consumerKey: String = "uH6FFqSPBi1ZG80I6taO5xt24"
    let consumerSecret: String = "0gIbzrGYW6CU2W3DoehwuLQz8SXojr8v5z5I2DaBPjm9kHbt16"

    let swifter: Swifter

    init(token oauthToken: String, secret oauthSecret: String) {
        self.swifter = Swifter(consumerKey: self.consumerKey,
                               consumerSecret: self.consumerSecret,
                               oauthToken: oauthToken,
                               oauthTokenSecret: oauthSecret)
    }

    func post(_ text: String, with artwork: NSImage? = nil, failure: Swifter.FailureHandler? = nil, success: @escaping Swifter.SuccessHandler) {
        guard let image = artwork?.toData(from: .jpeg) else {
            self.swifter.postTweet(status: text, success: success, failure: failure)
            return
        }

        self.swifter.postTweet(status: text, media: image, success: success, failure: failure)
    }

    func profile(account: SocialAccount, failure: Swifter.FailureHandler? = nil, success: @escaping Swifter.SuccessHandler) {
        self.swifter.showUser(.id(account.userID), success: success, failure: failure)
    }

}
