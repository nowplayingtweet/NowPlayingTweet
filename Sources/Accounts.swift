/**
 *  Accounts.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import KeychainAccess

class Accounts {

    static let shared = Accounts()

    private let userDefaults = UserDefaults.standard

    private var storage: [Provider : ProviderAccounts] = [:]

    var sortedAccounts: [Account] {
        var result: [Account] = []

        for provider in Provider.allCases {
            guard let accounts = self.storage[provider] else {
                continue
            }

            result += accounts.storage.keys.sorted().map { accounts.storage[$0]!.0 }
        }

        return result
    }

    var existsAccounts: Bool {
        return self.sortedAccounts.count > 0
    }

    var current: Account? {
        get {
            guard let provider = self.userDefaults.provider(forKey: "CurrentProvider")
                , let id = self.userDefaults.string(forKey: "CurrentAccountID")
                , let (account, _) = self.storage[provider]?.storage[id] else {
                    return nil
            }

            return account
        }

        set {
            guard let current = newValue else {
                self.userDefaults.removeObject(forKey: "CurrentProvider")
                self.userDefaults.removeObject(forKey: "CurrentAccountID")
                return
            }

            self.userDefaults.set(type(of: current).provider, forKey: "CurrentProvider")
            self.userDefaults.set(current.id, forKey: "CurrentAccountID")
        }
    }

    private init() {
        var providers: [Provider] = Provider.allCases

        var observer: NSObjectProtocol!
        observer = NotificationCenter.default.addObserver(forName: .socialAccountsInitialize, object: nil, queue: nil, using: { notification in
            guard let initalizedProvider = notification.userInfo?["provider"] as? Provider else {
                return
            }

            providers.removeAll { $0 == initalizedProvider }

            if providers.count > 0 {
                return
            }

            if self.current == nil {
                self.current = self.sortedAccounts.first
            }

            NotificationQueue.default.enqueue(.init(name: .alreadyAccounts, object: nil), postingStyle: .whenIdle)

            NotificationCenter.default.removeObserver(observer!)
        })

        for provider in Provider.allCases {
            if let providerAccounts = provider.accounts?.init(keychainPrefix: "com.kr-kp.NowPlayingTweet.Accounts") {
                self.storage[provider] = providerAccounts
            }
        }
    }

    func accountAndCredentials(_ provider: Provider, id: String) -> (Account, Credentials)? {
        return self.storage[provider]?.storage[id]
    }

    func account(_ provider: Provider, id: String) -> Account? {
        guard let (account, _) = accountAndCredentials(provider, id: id) else {
            return nil
        }
        return account
    }

    func credentials(_ provider: Provider, id: String) -> Credentials? {
        guard let (_, credentials) = accountAndCredentials(provider, id: id) else {
            return nil
        }
        return credentials
    }

    func client(for account: Account) -> Client? {
        let provider = type(of: account).provider
        guard let client = provider.client
            , let credentials = self.credentials(provider, id: account.id) else {
            return nil
        }
        return client.init(credentials)
    }

    func login(provider: Provider) {
        guard let client = provider.client
            , let (key, secret) = provider.clientKey else {
            return
        }

        client.authorize(key: key, secret: secret, callbackURLScheme: "nowplayingtweet", handler: { credentials in
            client.init(credentials)?.verify(handler: { account in
                self.storage[provider]?.saveToKeychain(account: account, credentials: credentials)

                if self.current == nil {
                    self.current = self.sortedAccounts.first
                }

                NotificationCenter.default.post(name: .login,
                                                object: nil,
                                                userInfo: ["account" : account])
            })
        })
    }

    func logout(account: Account) {
        let provider = type(of: account).provider
        guard let client = self.client(for: account) else {
            self.storage[provider]?.deleteFromKeychain(id: account.id)
            if self.current == nil {
                self.current = self.sortedAccounts.first
            }
            NotificationCenter.default.post(name: .logout,
                                            object: nil)
            return
        }

        client.revoke(handler: {
            self.storage[provider]?.deleteFromKeychain(id: account.id)
            if self.current == nil {
                self.current = self.sortedAccounts.first
            }
            NotificationCenter.default.post(name: .logout,
                                            object: nil)
        }, failure: { error in
            guard let err = error as? SocialError else {
                return
            }

            switch err {
            case .NotImplements(_, _):
                self.storage[provider]?.deleteFromKeychain(id: account.id)
                if self.current == nil {
                    self.current = self.sortedAccounts.first
                }
                NotificationCenter.default.post(name: .logout,
                                                object: nil)
            case .FailedRevoke(let message):
                NSLog(message)
            default:
                break
            }
        })

    }

}
