/**
 *  TwitterAccounts.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation
import KeychainAccess

class TwitterAccounts: ProviderAccounts {

    private(set) var storage: [String : (Account, Credentials)] = [:]

    private let apiKey: String = "uH6FFqSPBi1ZG80I6taO5xt24"
    private let apiSecret: String = "0gIbzrGYW6CU2W3DoehwuLQz8SXojr8v5z5I2DaBPjm9kHbt16"

    private let keychainPrefix: String

    private var keychainName: String {
        return "\(self.keychainPrefix).\(Provider.Twitter)"
    }

    required init(keychainPrefix: String) {
        self.keychainPrefix = keychainPrefix
        let keychain = Keychain(service: self.keychainName)

        var ids = keychain.allKeys()
        self.initializeNotification(ids.count)

        for id in keychain.allKeys() {
            guard let encodedCredentials: Data = try? keychain.getData(id)
                , let credentials: TwitterCredentials = try? JSONDecoder().decode(TwitterCredentials.self, from: encodedCredentials) else {
                    self.delete(id: id)
                    ids.removeAll { $0 == id }
                    self.initializeNotification(ids.count)
                    continue
            }

            TwitterClient(credentials)!.verify(success: {
                account in
                defer {
                    ids.removeAll { $0 == id }
                    self.initializeNotification(ids.count)
                }

                guard let account = account as? TwitterAccount else {
                    self.delete(id: id)
                    return
                }

                self.storage[id] = (account, credentials)
            }, failure: { _ in
                self.delete(id: id)
                ids.removeAll { $0 == id }
                self.initializeNotification(ids.count)
            })
        }
    }

    private func initializeNotification(_ count: Int) {
        if count == 0 {
            NotificationQueue.default.enqueue(.init(name: .socialAccountsInitialize,
                                                    object: nil,
                                                    userInfo: ["provider": Provider.Twitter]),
                                              postingStyle: .whenIdle)
        }
    }

    func authorize(handler: @escaping (Account?, Error?) -> Void) {
        let saveHandler: (TwitterAccount, TwitterCredentials) -> Void = { account, credentials in
            self.save(account: account, credentials: credentials)
            handler(account, nil)
        }

        let failure = { error in
            handler(nil, error)
        }

        let success: (Credentials) -> Void = { credentials in
            let credentials = credentials as! TwitterCredentials
            TwitterClient(credentials)?.verify(success: { account in
                let account = account as! TwitterAccount
                saveHandler(account, credentials)
            }, failure: failure)
        }

        TwitterClient.authorize(key: self.apiKey, secret: self.apiSecret, urlScheme: "nowplayingtweet", success: success, failure: failure)
    }

    private func save(account: TwitterAccount, credentials: TwitterCredentials) {
        guard let data: Data = try? JSONEncoder().encode(credentials) else {
            return
        }

        let keychain = Keychain(service: self.keychainName)
        try? keychain.set(data, key: account.id)
        self.storage[account.id] = (account, credentials)
    }

    func revoke(id: String, handler: @escaping (Error?) -> Void) {
        let deleteHandler: (Error?) -> Void = { error in
            self.delete(id: id)
            handler(error)
        }

        guard let (_, credentials) = self.storage[id]
            , let client = TwitterClient(credentials) else {
            deleteHandler(nil)
            return
        }

        client.revoke(success: {
            deleteHandler(nil)
        }, failure: { error in
            guard let err = error as? SocialError else {
                deleteHandler(error)
                return
            }

            switch err {
            case .NotImplements(_, _):
                deleteHandler(nil)
            default:
                deleteHandler(err)
            }
        })
    }

    private func delete(id: String) {
        let keychain = Keychain(service: self.keychainName)
        try? keychain.remove(id)
        self.storage.removeValue(forKey: id)
    }

}
