/**
 *  MastodonClient.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation
import AsyncHTTPClient

import AppKit

class MastodonClient: D14nClient, D14nAuthorizeByCallback, D14nAuthorizeByCode, PostAttachments {

    private struct RegisterApp: Codable {
        let id: String
        let secret: String

        enum CodingKeys: String, CodingKey {
            case id = "client_id"
            case secret = "client_secret"
        }
    }

    private struct Authorization: Codable {
        let token: String

        enum CodingKeys: String, CodingKey {
            case token = "access_token"
        }
    }

    static var callbackObserver: NSObjectProtocol?

    private static func callbackUri(_ urlScheme: String) -> String {
        return "\(urlScheme)://\(String(describing: Provider.Mastodon).lowercased())"
    }

    static func handleCallback(_ event: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue
            , let url = URL(string: urlString) else { return }

        let params = url.query?.queryParamComponents

        let userInfo = ["code" : params?["code"]]

        NotificationQueue.default.enqueue(.init(name: .callbackMastodon,
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
            "redirect_uris": Self.callbackUri(urlScheme),
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

    private static func openBrowser(base: String, key: String, secret: String, redirectUri: String) {
        let queryParams: [String : String] = [
            "client_id": key,
            "client_secret": secret,
            "redirect_uri": redirectUri,
            "scopes": "read write",
            "response_type": "code"
        ]
        let query: String = queryParams.urlencoded

        let queryUrl = URL(string: "\(base)/oauth/authorize?\(query)")!
        NSWorkspace.shared.open(queryUrl)
    }

    private static func authorization(base: String, key: String, secret: String, redirectUri: String, code: String, handler: @escaping (Result<HTTPClient.Response, Error>) -> Void) {
        let requestParams: [String : String] = [
            "client_id": key,
            "client_secret": secret,
            "redirect_uri": redirectUri,
            "scopes": "read write",
            "code": code,
            "grant_type": "authorization_code"
        ]

        let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        httpClient.post(url: "\(base)/oauth/token", headers: [
            ("Content-Type", "application/x-www-form-urlencoded"),
        ], body: .string(requestParams.urlencoded)).whenComplete { result in
            handler(result)

            httpClient.eventLoopGroup.shutdownGracefully({_ in
                try? httpClient.syncShutdown()
            })
        }
    }

    static func authorize(base: String, key: String, secret: String, urlScheme: String, success: @escaping Client.TokenSuccess, failure: Client.Failure?) {
        if !base.hasSchemeAndHost {
            failure?(SocialError.FailedAuthorize("Invalid base url"))
            return
        }

        Self.callbackObserver = NotificationCenter.default.addObserver(forName: .callbackMastodon, object: nil, queue: nil) { notification in
            guard let code = notification.userInfo?["code"] as? String else {
                failure?(SocialError.FailedAuthorize("Invalid authorization code"))
                NotificationCenter.default.removeObserver(Self.callbackObserver!)
                return
            }

            Self.authorization(base: base, key: key, secret: secret, redirectUri: Self.callbackUri(urlScheme), code: code) { result in
                defer {
                    NotificationCenter.default.removeObserver(Self.callbackObserver!)
                }

                switch result {
                case .failure(let error):
                    failure?(error)
                case .success(let response):
                    if response.status == .ok
                     , let body = response.body
                     , let res = try? body.getJSONDecodable(Authorization.self, at: 0, length: body.readableBytes) {
                        // handle response
                        success(MastodonCredentials(base: base, apiKey: key, apiSecret: secret, oauthToken: res.token))
                    } else {
                        // handle remote error
                        failure?(SocialError.FailedAuthorize(String(describing: response.status)))
                    }
                }
            }
        }

        Self.openBrowser(base: base, key: key, secret: secret, redirectUri: Self.callbackUri(urlScheme))
    }

    static func authorize(base: String, key: String, secret: String, failure: Client.Failure?) {
        if !base.hasSchemeAndHost {
            failure?(SocialError.FailedAuthorize("Invalid base url"))
            return
        }

        Self.openBrowser(base: base, key: key, secret: secret, redirectUri: "urn:ietf:wg:oauth:2.0:oob")

        NotificationCenter.default.post(name: .authorizeMastodon, object: nil)
    }

    static func requestToken(base: String, key: String, secret: String, code: String, success: @escaping Client.TokenSuccess, failure: Client.Failure?) {
        if !base.hasSchemeAndHost {
            failure?(SocialError.FailedAuthorize("Invalid base url"))
            return
        }

        Self.authorization(base: base, key: key, secret: secret, redirectUri: "urn:ietf:wg:oauth:2.0:oob", code: code) { result in
            switch result {
            case .failure(let error):
                failure?(error)
            case .success(let response):
                if response.status == .ok
                 , let body = response.body
                 , let res = try? body.getJSONDecodable(Authorization.self, at: 0, length: body.readableBytes) {
                    // handle response
                    success(MastodonCredentials(base: base, apiKey: key, apiSecret: secret, oauthToken: res.token))
                } else {
                    // handle remote error
                    failure?(SocialError.FailedAuthorize(String(describing: response.status)))
                }
            }
        }
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
