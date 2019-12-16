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

    private var storage: [Provider : ProviderAccounts] = [:]

    var sortedAccounts: [Account] {
        var result: [Account] = []

        for provider in Provider.allCases {
            guard let accounts = self.storage[provider] else {
                continue
            }

            for id in accounts.storage.keys.sorted() {
                guard let (account, _) = accounts.storage[id] else {
                    continue
                }

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
                , let (account, _) = self.storage[provider]?.storage[id] else {
                    return nil
            }

            return account
        }

        set {
            guard let current = newValue else {
                UserDefaults.standard.removeObject(forKey: "CurrentProvider")
                UserDefaults.standard.removeObject(forKey: "CurrentAccountID")
                UserDefaults.standard.synchronize()
                return
            }

            UserDefaults.standard.set(type(of: current).provider, forKey: "CurrentProvider")
            UserDefaults.standard.set(current.id, forKey: "CurrentAccountID")
            UserDefaults.standard.synchronize()
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
            self.storage[provider] = provider.accounts.init(keychainPrefix: "com.kr-kp.NowPlayingTweet.Accounts")
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

    func client(for account: Account) -> Client {
        let provider = type(of: account).provider
        return provider.client.init(self.credentials(provider, id: account.id)!)!
    }

    func login(provider: Provider) {
        provider.client.authorize(callbackURLScheme: "nowplayingtweet", handler: { credentials in
            provider.client.init(credentials)?.verify(handler: { account in
                let provider = type(of: account).provider

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
        let id = account.id

        self.storage[provider]?.deleteFromKeychain(id: id)

        if self.current == nil {
            self.current = self.sortedAccounts.first
        }

        NotificationCenter.default.post(name: .logout,
                                        object: nil)
    }

}
