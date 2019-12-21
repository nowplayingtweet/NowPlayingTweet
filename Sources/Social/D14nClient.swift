/**
 *  D14nClient.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol D14nClient: Client {

    static func registerApp(base: URL?, success: @escaping (String, String) -> Void, failure: Client.Failure?)

}

extension D14nClient {

    static func registerApp(base baseURL: URL?, success: @escaping (String, String) -> Void) {
        Self.registerApp(base: baseURL, success: success, failure: nil)
    }

}
