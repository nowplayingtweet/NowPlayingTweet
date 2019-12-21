/**
 *  AuthorizeByCallback.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol AuthorizeByCallback {

    static func handleCallback(_: NSAppleEventDescriptor)

    static func authorize(key: String, secret: String, callbackURLScheme: String, success: @escaping Client.TokenSuccess, failure: Client.Failure?)

}

extension AuthorizeByCallback {

    static func authorize(key: String, secret: String, callbackURLScheme: String, success: @escaping Client.TokenSuccess) {
        Self.authorize(key: key, secret: secret, callbackURLScheme: callbackURLScheme, success: success, failure: nil)
    }

}
