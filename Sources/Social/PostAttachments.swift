/**
 *  PostAttachments.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol PostAttachments {

    func post(text: String, image: Data?, success: Client.Success?, failure: Client.Failure?)

}

extension PostAttachments {

    func post(text: String, image: Data?) {
        self.post(text: text, image: image, success: nil, failure: nil)
    }

}

extension PostAttachments where Self: Client {

    func post(text: String, success: Client.Success?, failure: Client.Failure?) {
        self.post(text: text, image: nil, success: success, failure: failure)
    }

}
