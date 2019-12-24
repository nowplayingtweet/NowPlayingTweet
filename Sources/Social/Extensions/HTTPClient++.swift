/**
 *  HTTPClient++.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation
import AsyncHTTPClient
import NIO
import NIOHTTP1

extension HTTPClient {

    public func get(url: String, headers: [(String, String)] = [], deadline: NIODeadline? = nil) -> EventLoopFuture<Response> {
        do {
            var request = try Request(url: url, method: .GET, headers: HTTPHeaders(headers))
            request.headers.add(name: "User-Agent", value: Bundle.main.displayName ?? "Swift Social Media Provider")
            return self.execute(request: request, deadline: deadline)
        } catch {
            return self.eventLoopGroup.next().makeFailedFuture(error)
        }
    }

    public func post(url: String, headers: [(String, String)] = [], body: Body? = nil, deadline: NIODeadline? = nil) -> EventLoopFuture<Response> {
        do {
            var request = try Request(url: url, method: .POST, headers: HTTPHeaders(headers), body: body)
            request.headers.add(name: "User-Agent", value: Bundle.main.displayName ?? "Swift Social Media Provider")
            return self.execute(request: request, deadline: deadline)
        } catch {
            return self.eventLoopGroup.next().makeFailedFuture(error)
        }
    }

}
