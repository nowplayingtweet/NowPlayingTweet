/**
 *  PostAttachments.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol PostAttachments {

    func post(visibility: String, text: String, image: Data?, success: Client.Success?, failure: Client.Failure?)

}

extension PostAttachments {

    func post(text: String, image: Data?, success: Client.Success? = nil, failure: Client.Failure? = nil) {
        self.post(visibility: "", text: text, image: image, success: success, failure: failure)
    }

}

extension PostAttachments where Self: Client {

    func post(visibility: String, text: String, success: Client.Success?, failure: Client.Failure?) {
        self.post(visibility: visibility, text: text, image: nil, success: success, failure: failure)
    }

}
