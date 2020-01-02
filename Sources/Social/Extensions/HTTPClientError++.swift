/**
 *  HTTPClientError++.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation
import AsyncHTTPClient
import NIO

extension HTTPClientError: LocalizedError {

    public var errorDescription: String? {
        return self.description
    }

}

extension EventLoopError: LocalizedError {

    public var errorDescription: String? {
        return String(describing: self)
    }

}
