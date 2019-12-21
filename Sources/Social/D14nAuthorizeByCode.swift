/**
 *  D14nAuthorizeByCode.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol D14nAuthorizeByCode: AuthorizeByCode {

    static func authorize(base: URL?, key: String, secret: String, failure: Client.Failure?)

    static func authorization(base: URL?, code: String, success: @escaping Client.TokenSuccess, failure: Client.Failure?)

}

extension D14nAuthorizeByCode {

    static func authorize(base baseURL: URL?, key: String, secret: String) {
        Self.authorize(base: baseURL, key: key, secret: secret, failure: nil)
    }

    static func authorization(base baseURL: URL?, code: String, success: @escaping Client.TokenSuccess) {
        Self.authorization(base: baseURL, code: code, success: success, failure: nil)
    }

    static func authorize(key: String, secret: String, failure: Client.Failure?) {
        Self.authorize(base: nil, key: key, secret: secret, failure: failure)
    }

    static func authorization(code: String, success: @escaping Client.TokenSuccess, failure: Client.Failure?) {
        Self.authorization(base: nil, code: code, success: success, failure: failure)
    }

}
