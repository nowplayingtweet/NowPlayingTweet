/**
 *  Client.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol Client {

    typealias Success = () -> Void
    typealias TokenSuccess = (Credentials) -> Void
    typealias AccountSuccess = (Account) -> Void
    typealias Failure = (Error) -> Void

    var credentials: Credentials { get }

    init?(_: Credentials)

    func revoke(success: Success?, failure: Failure?)

    func verify(success: @escaping AccountSuccess, failure: Failure?)

    func post(visibility: String, text: String, success: Success?, failure: Failure?)

}

extension Client {

    func revoke() {
        self.revoke(success: nil, failure: nil)
    }

    func verify(success: @escaping AccountSuccess) {
        self.verify(success: success, failure: nil)
    }

    func post(text: String, success: Success? = nil, failure: Failure? = nil) {
        self.post(visibility: "", text: text, success: success, failure: failure)
    }

}
