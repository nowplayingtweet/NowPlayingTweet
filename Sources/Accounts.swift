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

    var availableProviders: [Provider] {
        return Provider.allCases.filter { self.storage.keys.contains($0) }
    }

    var sortedAccounts: [Account] {
        var result: [Account] = []

        for provider in self.availableProviders {
            if let accounts = self.storage[provider] {
                result += accounts.storage.keys.sorted().map { accounts.storage[$0]!.0 }
            }
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
            self.userDefaults.set(current.keychainID, forKey: "CurrentAccountID")
        }
    }

    private init() {
        var providers: [Provider] = Provider.allCases

        var token: NSObjectProtocol?
        token = NotificationCenter.default.addObserver(forName: .socialAccountsInitialize, object: nil, queue: nil, using: { notification in
            guard let initalizedProvider = notification.userInfo?["provider"] as? Provider else {
                return
            }

            providers.removeAll { $0 == initalizedProvider }

            if providers.count > 0 {
                return
            }

            NotificationQueue.default.enqueue(.init(name: .alreadyAccounts, object: nil), postingStyle: .asap)

            if self.current == nil {
                self.current = self.sortedAccounts.first
            }

            NotificationCenter.default.removeObserver(token!)
        })

        for provider in providers {
            if let providerAccounts = provider.accounts?.init(keychainPrefix: "com.kr-kp.NowPlayingTweet.Accounts") {
                self.storage[provider] = providerAccounts
                continue
            }

            providers.removeAll { $0 == provider }

            if providers.count > 0 {
                continue
            }

            NotificationQueue.default.enqueue(.init(name: .alreadyAccounts, object: nil), postingStyle: .asap)

            if self.current == nil {
                self.current = self.sortedAccounts.first
            }

            NotificationCenter.default.removeObserver(token!)
        }
    }

    func post(with account: Account, text: String, image: Data?, success: Client.Success?, failure: Client.Failure?) {
        let provider = type(of: account).provider
        let accountSetting = UserDefaults.standard.accountSetting(forKey: account.keychainID)
        guard let (_, credentials) = self.storage[provider]?.storage[account.keychainID]
            , let client = provider.client?.init(credentials) else {
                failure?(NPTError.Unknown("Invalid credentials"))
                return
        }

        var visibility = accountSetting["Visibility"] as? String ?? ""
        if visibility == "Default" {
            visibility = ""
        }

        if let client = client as? PostAttachments {
            let sensitive = accountSetting["SensitiveImage"] as? Bool ?? false
            client.post(visibility: visibility, text: text, image: image, sensitive: sensitive, success: success, failure: failure)
        } else {
            client.post(visibility: visibility, text: text, success: success, failure: failure)
        }
    }

    func login(provider: Provider, base: String = "") {
        guard let accounts = self.storage[provider] else {
            return
        }

        let handler: (Account?, Error?) -> Void = { account, error in
            if let error = error {
                NSLog(error.localizedDescription)
                return
            }

            guard let account = account else {
                return
            }

            if self.current == nil {
                self.current = self.sortedAccounts.first
            }

            NotificationCenter.default.post(name: .login,
                                            object: nil,
                                            userInfo: ["account" : account])
        }

        if let accounts = accounts as? D14nProviderAccounts {
            accounts.authorize(base: base, handler: handler)
        } else {
            accounts.authorize(handler: handler)
        }
    }

    func logout(account: Account) {
        let provider = type(of: account).provider
        guard let accounts = self.storage[provider] else {
            NotificationCenter.default.post(name: .logout,
                                            object: nil)

            return
        }

        accounts.revoke(id: account.keychainID) { error in
            if let error = error {
                NSLog(error.localizedDescription)
                return
            }

            if self.current == nil {
                self.current = self.sortedAccounts.first
            }
            NotificationCenter.default.post(name: .logout,
                                            object: nil)
        }
    }

}
