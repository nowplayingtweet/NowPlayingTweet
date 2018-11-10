/**
 *  SocialAccounts.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import KeychainAccess

class SocialAccounts {

    static let shared = SocialAccounts()

    let keychain = Keychain(service: "com.kr-kp.NowPlayingTweet.AccountToken")

    private(set) var current: SocialAccount? {
        get {
            guard let currentID = UserDefaults.standard.string(forKey: "CurrentAccount") else {
                let accountID = self.accountIDs[safe: 0]
                if accountID == nil { return nil }

                let account = self.accounts[accountID!]!
                let name = account.providerName.rawValue + "-" + account.userID
                UserDefaults.standard.set(name, forKey: "CurrentAccount")

                return account
            }
            let currentName: [String] = currentID.split(separator: "-").map { String($0) }

            if currentName.indices.contains(1) {
                return self.get(Provider.Name(currentName[0]), userID: currentName[1])
            } else {
                UserDefaults.standard.set(Provider.Name.twitter.rawValue + "-" + currentName[0], forKey: "CurrentAccount")
                return self.get(.twitter, userID: currentName[0])
            }

        }
        
        set {
            guard let account = newValue else {
                return
            }
            UserDefaults.standard.set(account.providerName.rawValue + "-" + account.userID, forKey: "CurrentAccount")
        }
    }

    var existsAccount: Bool {
        return !self.accounts.isEmpty
    }

    var count: Int {
        return self.accounts.count
    }

    private var accountIDs: [String] {
        return self.accounts.keys.sorted()
    }

    private var accounts: [String:SocialAccount] = [:]

    private init() {
        let accountIDs = self.keychain.allKeys().sorted()

        for accountID in accountIDs {
            guard let data: Data? = try? self.keychain.getData(accountID), let accountData: Data = data else {
                continue
            }

            let accountInfo: [String : String] = NSKeyedUnarchiver.unarchiveObject(with: accountData) as! [String : String]

            let providerName: Provider.Name = Provider.Name(accountInfo["providerName"] ?? "Twitter")
            let oauthToken: String = accountInfo["oauthToken"]!
            let oauthSecret: String? = accountInfo["oauthSecret"]
            let userID: String = accountInfo["userID"] ?? accountID
            let name: String? = accountInfo["name"]
            let screenName: String? = accountInfo["screenName"]
            let avaterUrl: String = accountInfo["avaterUrl"] ?? ""

            let account = SocialAccount(providerName,
                                        oauthToken: oauthToken,
                                        oauthSecret: oauthSecret,
                                        userID: userID,
                                        name: name,
                                        screenName: screenName,
                                        avaterUrl: avaterUrl)

            self.accounts[account.providerName.rawValue + "-" + account.userID] = account
        }
    }

    func all() -> [SocialAccount] {
        return self.accounts.values.map { $0 }
    }

    subscript (index: Int) -> SocialAccount? {
        guard let accountID = self.accountIDs[safe: index] else {
            return nil
        }

        return self.accounts[accountID]
    }

    func index(of account: SocialAccount) -> Int? {
        let key = self.accounts.first { arg in
            let (_, value) = arg
            return value.providerName == account.providerName && value.userID == account.userID
        }?.key
        return self.accountIDs.index(of: key ?? "")
    }

    func get(_ provider: Provider.Name, userID: String) -> SocialAccount? {
        return self.accounts.first { _, value in
            return value.providerName == provider && value.userID == userID
        }?.value
    }

    func get(_ provider: Provider.Name, screenName: String) -> SocialAccount? {
        return self.accounts.first { _, value in
            return value.providerName == provider && value.screenName == screenName
        }?.value
    }

    func changeCurrent(to account: SocialAccount) {
        self.current = account
    }

}
