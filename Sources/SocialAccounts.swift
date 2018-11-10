/**
 *  SocialAccounts.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import KeychainAccess

class SocialAccounts {

    static let shared = SocialAccounts()

    let keychain = Keychain(service: "com.kr-kp.NowPlayingTweet.AccountToken")

    var current: SocialAccount? {
        get {
            return self.accounts[safe: 0]
        }
        
        set {
            
        }
    }

    var existsAccount: Bool {
        return !self.accounts.isEmpty
    }

    var count: Int {
        return self.accounts.count
    }

    private var accounts: [SocialAccount] = []

    private init() {
        let accountIDs = self.keychain.allKeys()

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

            self.accounts.append(account)
        }
    }

    func all() -> [SocialAccount] {
        return self.accounts
    }

    subscript (index: Int) -> SocialAccount? {
        return self.accounts[safe: index]
    }

    func index(of account: SocialAccount) -> Int? {
        return self.accounts.firstIndex(where: { $0.providerName == account.providerName && $0.userID == account.userID })
    }

    func get(_ provider: Provider.Name, userID: String) -> SocialAccount? {
        return self.accounts.first { $0.providerName == provider && $0.userID == userID }
    }

    func get(_ provider: Provider.Name, screenName: String) -> SocialAccount? {
        return self.accounts.first { $0.providerName == provider && $0.screenName == screenName }
    }

    func changeCurrent(to account: SocialAccount) {
        let name = account.providerName.rawValue + "-" + account.userID
        UserDefaults.standard.set(name, forKey: "CurrentAccount")
    }

}
