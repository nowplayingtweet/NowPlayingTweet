/**
 *  AuthorizeByCode.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol AuthorizeByCode {

    static func authorize(key: String, secret: String, failure: Client.Failure?)

    static func requestToken(key: String, secret: String, code: String, success: @escaping Client.TokenSuccess, failure: Client.Failure?)

}

extension AuthorizeByCode {

    static func authorize(key: String, secret: String) {
        Self.authorize(key: key, secret: secret, failure: nil)
    }

    static func requestToken(key: String, secret: String, code: String, success: @escaping Client.TokenSuccess) {
        Self.requestToken(key: key, secret: secret, code: code, success: success, failure: nil)
    }

}
