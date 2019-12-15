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

    private var userDefaults: UserDefaults = UserDefaults.standard

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
        if !self.existsAccounts {
            return nil
        }

        return self.accounts[self.currentID!]
    }

    var currentID: String? {
        self.updateCurrentAccount()

        return self.userDefaults.string(forKey: "CurrentAccount")
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

            self.updateCurrentAccount()

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

    func login(provider: Provider) {
        provider.client.authorize(callbackURLScheme: "nowplayingtweet", handler: { credentials in
            provider.client.init(credentials)?.verify(handler: { account in
                let provider = type(of: account).provider

                self.storage[provider]!.saveToKeychain(account: account, credentials: credentials)

                self.updateCurrentAccount()

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

        self.updateCurrentAccount()

        NotificationCenter.default.post(name: .logout,
                                        object: nil)
    }

    func tweet(account: Account, text: String, with artwork: Data? = nil, success: Swifter.SuccessHandler? = nil, failure: Swifter.FailureHandler? = nil) {
        /*
        if artwork == nil {
            account.swifter.postTweet(status: text, success: success, failure: failure)
            return
        }

        account.swifter.postTweet(status: text, media: artwork!, success: success, failure: failure)
         */
    }

    private func updateCurrentAccount() {
        if self.existsAccounts {
            let userID = self.sortedAccounts.first
            self.changeCurrent(userID: userID!)
        } else {
            self.userDefaults.removeObject(forKey: "CurrentAccount")
            self.userDefaults.synchronize()
        }
    }

    func changeCurrent(userID: String) {
        self.userDefaults.set(userID, forKey: "CurrentAccount")
        self.userDefaults.synchronize()
    }

}
