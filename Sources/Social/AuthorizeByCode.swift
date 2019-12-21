/**
 *  AuthorizeByCode.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol AuthorizeByCode {

    static func authorize(key: String, secret: String, failure: Client.Failure?)

    static func authorization(code: String, success: @escaping Client.TokenSuccess, failure: Client.Failure?)

}

extension AuthorizeByCode {

    static func authorize(key: String, secret: String) {
        Self.authorize(key: key, secret: secret, failure: nil)
    }

    static func authorization(code: String, success: @escaping Client.TokenSuccess) {
        Self.authorization(code: code, success: success, failure: nil)
    }

}
