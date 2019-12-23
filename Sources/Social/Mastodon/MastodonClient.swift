/**
 *  MastodonClient.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

class MastodonClient: D14nClient, D14nAuthorizeByCallback, D14nAuthorizeByCode, PostAttachments {

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

    static func registerApp(base: String, name: String, urlScheme: String, success: D14nClient.RegisterSuccess, failure: Client.Failure?) {
        failure?(SocialError.NotImplements(className: NSStringFromClass(MastodonClient.self), function: #function))
    }

    static func authorize(base: String, key: String, secret: String, urlScheme: String, success: Client.TokenSuccess, failure: Client.Failure?) {
        failure?(SocialError.NotImplements(className: NSStringFromClass(MastodonClient.self), function: #function))
    }

    static func registerApp(base: String, name: String, success: D14nClient.RegisterSuccess, failure: Client.Failure?) {
        failure?(SocialError.NotImplements(className: NSStringFromClass(MastodonClient.self), function: #function))
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
