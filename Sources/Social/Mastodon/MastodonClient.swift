/**
 *  MastodonClient.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation
import AsyncHTTPClient

class MastodonClient: D14nClient, D14nAuthorizeByCallback, D14nAuthorizeByCode, PostAttachments {

    private struct RegisterApp: Codable {
        let id: String
        let secret: String

        enum CodingKeys: String, CodingKey {
            case id = "client_id"
            case secret = "client_secret"
        }
    }

    static func handleCallback(_ event: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue
            , let url = URL(string: urlString) else { return }

        let params = url.query?.queryParamComponents

        let userInfo = ["code" : params?["code"]]

        NotificationQueue.default.enqueue(.init(name: .mastodonCallback,
                                                object: nil,
                                                userInfo: userInfo as [AnyHashable : Any]),
                                          postingStyle: .asap)
    }

    static func registerApp(base: String, name: String, urlScheme: String, success: @escaping D14nClient.RegisterSuccess, failure: Client.Failure?) {
        if !base.hasSchemeAndHost {
            failure?(SocialError.FailedAuthorize("Invalid base url"))
            return
        }

        let requestParams: [String : String] = [
            "client_name": name,
            "redirect_uris": "\(urlScheme)://\(String(describing: Provider.Mastodon).lowercased())",
            "scopes": "read write",
        ]

        let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        httpClient.post(url: "\(base)/api/v1/apps", headers: [
            ("Content-Type", "application/x-www-form-urlencoded"),
        ], body: .string(requestParams.urlencoded)).whenComplete { result in
            defer {
                httpClient.eventLoopGroup.shutdownGracefully({_ in
                    try? httpClient.syncShutdown()
                })
            }

            switch result {
            case .failure(let error):
                failure?(error)
            case .success(let response):
                if response.status == .ok
                 , let body = response.body
                 , let client = try? body.getJSONDecodable(RegisterApp.self, at: 0, length: body.readableBytes) {
                    // handle response
                    success(client.id, client.secret)
                } else {
                    // handle remote error
                    failure?(SocialError.FailedAuthorize(String(describing: response.status)))
                }
            }
        }
    }

    static func authorize(base: String, key: String, secret: String, urlScheme: String, success: Client.TokenSuccess, failure: Client.Failure?) {
        failure?(SocialError.NotImplements(className: NSStringFromClass(MastodonClient.self), function: #function))
    }

    static func registerApp(base: String, name: String, success: @escaping D14nClient.RegisterSuccess, failure: Client.Failure?) {
        if !base.hasSchemeAndHost {
            failure?(SocialError.FailedAuthorize("Invalid base url"))
            return
        }

        let requestParams: [String : String] = [
            "client_name": name,
            "redirect_uris": "urn:ietf:wg:oauth:2.0:oob",
            "scopes": "read write",
        ]

        let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        httpClient.post(url: "\(base)/api/v1/apps", headers: [
            ("Content-Type", "application/x-www-form-urlencoded"),
        ], body: .string(requestParams.urlencoded)).whenComplete { result in
            defer {
                httpClient.eventLoopGroup.shutdownGracefully({_ in
                    try? httpClient.syncShutdown()
                })
            }

            switch result {
            case .failure(let error):
                failure?(error)
            case .success(let response):
                if response.status == .ok
                 , let body = response.body
                 , let client = try? body.getJSONDecodable(RegisterApp.self, at: 0, length: body.readableBytes) {
                    // handle response
                    success(client.id, client.secret)
                } else {
                    // handle remote error
                    failure?(SocialError.FailedAuthorize(String(describing: response.status)))
                }
            }
        }
    }

    static func authorize(base: String, key: String, secret: String, failure: Client.Failure?) {
        failure?(SocialError.NotImplements(className: NSStringFromClass(MastodonClient.self), function: #function))
    }

    static func authorization(base: String, code: String, success: Client.TokenSuccess, failure: Client.Failure?) {
        failure?(SocialError.NotImplements(className: NSStringFromClass(MastodonClient.self), function: #function))
    }

    let credentials: Credentials

    required init?(_ credentials: Credentials) {
        guard let credentials = credentials as? MastodonCredentials else {
            return nil
        }

        self.credentials = credentials
    }

    func revoke(success: Client.Success?, failure: Client.Failure?) {
        failure?(SocialError.NotImplements(className: NSStringFromClass(type(of: self)), function: #function))
    }

    func verify(success: Client.AccountSuccess, failure: Client.Failure?) {
        failure?(SocialError.NotImplements(className: NSStringFromClass(type(of: self)), function: #function))
    }

    func post(text: String, image: Data?, success: Client.Success?, failure: Client.Failure?) {
        failure?(SocialError.NotImplements(className: NSStringFromClass(type(of: self)), function: #function))
    }

}
