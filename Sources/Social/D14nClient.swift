/**
 *  D14nClient.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol D14nClient: Client {

    typealias RegisterSuccess = (String, String) -> Void

    static func registerApp(base: URL?, success: @escaping RegisterSuccess, failure: Client.Failure?)

}

extension D14nClient {

    static func registerApp(base baseURL: URL?, success: @escaping RegisterSuccess) {
        Self.registerApp(base: baseURL, success: success, failure: nil)
    }

}
