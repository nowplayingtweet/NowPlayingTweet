/**
 *  Accounts.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import SwifterMac
import KeychainAccess

class Accounts {

    static let shared: Accounts = Accounts()

    private let consumerKey: String = "uH6FFqSPBi1ZG80I6taO5xt24"
    private let consumerSecret: String = "0gIbzrGYW6CU2W3DoehwuLQz8SXojr8v5z5I2DaBPjm9kHbt16"

    private let keychain = Keychain(service: "com.kr-kp.NowPlayingTweet.AccountToken")

    private var storage: [Provider : ProviderAccounts] = [:]

    var sortedAccounts: [Account] {
        var result: [Account] = []

        for provider in Provider.allCases {
            guard let accounts = self.storage[provider] else {
                continue
            }

            for id in accounts.storage.keys.sorted() {
                let (account, _) = accounts.storage[id]!
                result.append(account)
            }
        }

        return result
    }

    var existsAccounts: Bool {
        return self.sortedAccounts.count > 0
    }

    var current: Account? {
        get {
            guard let provider = UserDefaults.standard.provider(forKey: "CurrentProvider")
                , let id = UserDefaults.standard.string(forKey: "CurrentAccountID")
                , let (account, _) = self.storage[provider]!.storage[id] else {
                    return nil
            }

            return account
        }

        set {
            guard let current = newValue else {
                UserDefaults.standard.removeObject(forKey: "CurrentProvider")
                UserDefaults.standard.removeObject(forKey: "CurrentAccountID")
                return
            }

            UserDefaults.standard.set(type(of: current).provider, forKey: "CurrentProvider")
            UserDefaults.standard.set(current.id, forKey: "CurrentAccountID")
        }
    }

    private init() {
        var providers: [Provider] = Provider.allCases

        for provider in providers {
            self.storage[provider] = provider.accounts.init(keychainPrefix: "com.kr-kp.NowPlayingTweet.Accounts")
        }

        var observer: NSObjectProtocol!
        observer = NotificationCenter.default.addObserver(forName: .socialAccountsInitialize, object: nil, queue: nil, using: { notification in
            guard let initalizedProvider = notification.userInfo?["provider"] as? Provider else {
                return
            }

            providers.removeAll { $0 == initalizedProvider }

            if providers.count != 0 {
                return
            }

            if self.current == nil {
                self.current = self.sortedAccounts.first
            }

            NotificationCenter.default.post(name: .alreadyAccounts,
                                            object: nil)

            NotificationCenter.default.removeObserver(observer!)
        })
    }

    func accountAndCredentials(_ provider: Provider, id: String) -> (Account, Credentials)? {
        return self.storage[provider]!.storage[id]
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

    func client(for account: Account) -> Client {
        let provider = type(of: account).provider
        return provider.client.init(self.credentials(provider, id: account.id)!)!
    }

    func login(provider: Provider) {
        provider.client.authorize(callbackURLScheme: "nowplayingtweet", handler: { credentials in
            provider.client.init(credentials)?.verify(handler: { account in
                let provider = type(of: account).provider

                self.storage[provider]!.saveToKeychain(account: account, credentials: credentials)

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
        let id = account.id

        self.storage[provider]!.deleteFromKeychain(id: id)

        if self.current == nil {
            self.current = self.sortedAccounts.first
        }

        NotificationCenter.default.post(name: .logout,
                                        object: nil)
    }

}
