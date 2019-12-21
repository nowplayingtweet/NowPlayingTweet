/**
 *  MastodonAccounts.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation
import KeychainAccess

class MastodonAccounts: D14nProviderAccounts {

    private(set) var storage: [String : (Account, Credentials)] = [:]

    private let keychainPrefix: String

    private var keychainName: String {
        return "\(self.keychainPrefix).\(Provider.Mastodon)"
    }

    required init(keychainPrefix: String) {
        self.keychainPrefix = keychainPrefix
        let keychain = Keychain(service: self.keychainName)

        var ids = keychain.allKeys()
        self.initializeNotification(ids.count)

        for id in keychain.allKeys() {
            guard let encodedCredentials: Data = try? keychain.getData(id)
                , let credentials: MastodonCredentials = try? JSONDecoder().decode(MastodonCredentials.self, from: encodedCredentials) else {
                    self.delete(id: id)
                    ids.removeAll { $0 == id }
                    self.initializeNotification(ids.count)
                    continue
            }

            MastodonClient(credentials)!.verify(success: {
                account in
                defer {
                    ids.removeAll { $0 == id }
                    self.initializeNotification(ids.count)
                }

                guard let account = account as? MastodonAccount else {
                    self.delete(id: id)
                    return
                }

                self.storage[id] = (account, credentials)
            }, failure: { _ in
                // TODO: Tokenが失効している時のフォールバックが必要
                ids.removeAll { $0 == id }
                self.initializeNotification(ids.count)
            })
        }
    }

    private func initializeNotification(_ count: Int) {
        if count == 0 {
            NotificationQueue.default.enqueue(.init(name: .socialAccountsInitialize,
                                                    object: nil,
                                                    userInfo: ["provider": Provider.Mastodon]),
                                              postingStyle: .whenIdle)
        }
    }

    func authorize(base: String, handler: @escaping (Account?, Error?) -> Void) {
        let saveHandler: (MastodonAccount, MastodonCredentials) -> Void = { account, credentials in
            self.save(account: account, credentials: credentials)
            handler(account, nil)
        }

        let failure = { error in
            handler(nil, error)
        }

        let success: (Credentials) -> Void = { credentials in
            let credentials = credentials as! MastodonCredentials
            MastodonClient(credentials)?.verify(success: { account in
                let account = account as! MastodonAccount
                saveHandler(account, credentials)
            }, failure: failure)
        }

        MastodonClient.registerApp(base: base, success: { key, secret in
            MastodonClient.authorize(base: base, key: key, secret: secret, urlScheme: "nowplayingtweet", success: success, failure: failure)
        }, failure: failure)
    }

    private func save(account: MastodonAccount, credentials: MastodonCredentials) {
        guard let data: Data = try? JSONEncoder().encode(credentials) else {
            return
        }

        let keychain = Keychain(service: self.keychainName)
        try? keychain.set(data, key: account.keychainID)
        self.storage[account.keychainID] = (account, credentials)
    }

    func revoke(id: String, handler: @escaping (Error?) -> Void) {
        let deleteHandler: (Error?) -> Void = { error in
            self.delete(id: id)
            handler(error)
        }

        guard let (_, credentials) = self.storage[id]
            , let client = MastodonClient(credentials) else {
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
