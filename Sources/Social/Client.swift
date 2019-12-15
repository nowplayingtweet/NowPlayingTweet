/**
 *  Client.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol Client {
    typealias Success = () -> Void
    typealias Failure = (Error) -> Void

    static func authorize(handler: ((Credentials) -> Void)?, failure: Failure?)

    var credentials: Credentials { get }

    init?(_: Credentials)

    func revoke(handler: Success?, failure: Failure?)

    func verify(handler: ((Account) -> Void)?, failure: Failure?)

    func post(text: String, image: Data?, handler: Success?, failure: Failure?)
}

extension Client {
    static func authorize(handler: ((Credentials) -> Void)? = nil, failure: Failure? = nil) {
        return Self.authorize(handler: handler, failure: failure)
    }

    func revoke(handler: Success? = nil, failure: Failure? = nil) {
        return self.revoke(handler: handler, failure: failure)
    }

    func verify(handler: ((Account) -> Void)? = nil, failure: Failure? = nil) {
        return self.verify(handler: handler, failure: failure)
    }

    func post(text: String, image: Data? = nil, handler: Success? = nil, failure: Failure? = nil) {
        return self.post(text: text, image: image, handler: handler, failure: failure)
    }
}
