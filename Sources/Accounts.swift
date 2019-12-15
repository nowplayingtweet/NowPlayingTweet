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

    private let notificationCenter: NotificationCenter = NotificationCenter.default

    private var accounts: [String : Account] = [:]

    var accountIDs: [String] {
        return self.accounts.keys.sorted()
    }

    var existsAccounts: Bool {
        return self.accounts.count > 0
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
        let accounts = self.keychain.allKeys()

        let failure: Swifter.FailureHandler = { error in
            let err = error as! SwifterError
            NSLog(err.localizedDescription)
        }

        var numOfAccounts: Int = accounts.count
        var observer: NSObjectProtocol!
        observer = self.notificationCenter.addObserver(forName: .initializeAccounts, object: nil, queue: nil, using: { _ in
            numOfAccounts -= 1
            if numOfAccounts > 0 {
                return
            }

            self.notificationCenter.removeObserver(observer!)

            self.updateCurrentAccount()

            self.notificationCenter.post(name: .alreadyAccounts,
                                         object: nil)
        })

        //for account in accounts {
        for account in accounts {
            let userID = account
            let token: Data? = try! self.keychain.getData(userID)
            let accountToken: [String : String?] = NSKeyedUnarchiver.unarchiveObject(with: token!) as! [String : String?]

            let oauthToken = accountToken["oauthToken"]!!
            let oauthSecret = accountToken["oauthSecret"]!!

            let swifter = Swifter(consumerKey: self.consumerKey,
                                  consumerSecret: self.consumerSecret,
                                  oauthToken: oauthToken,
                                  oauthTokenSecret: oauthSecret)

            self.setAccount(swifter: swifter,
                            userID: userID,
                            oauthToken: oauthToken,
                            oauthSecret: oauthSecret,
                            failure: failure,
                            notificationName: .initializeAccounts)
        }

        if numOfAccounts == 0 {
            self.notificationCenter.post(name: .alreadyAccounts,
                                         object: nil)
            return
        }
    }

    func account(name: String) -> Account? {
        return self.accounts.first { $0.value.name == name }?.value
    }

    func account(screenName: String) -> Account? {
        return self.accounts.first { $0.value.username == screenName }?.value
    }

    func account(userID: String) -> Account? {
        return self.accounts[userID]
    }

    func login() {
        let swifter = Swifter(consumerKey: self.consumerKey,
                              consumerSecret: self.consumerSecret)

        let failure: Swifter.FailureHandler = { error in
            let err = error as! SwifterError
            NSLog(err.localizedDescription)
        }

        let success: Swifter.TokenSuccessHandler = { accessToken, response in
            let oauthToken = accessToken?.key
            let oauthSecret = accessToken?.secret

            let userID = accessToken?.userID

            let accountToken = ["oauthToken" : oauthToken,
                                "oauthSecret" : oauthSecret]

            let tokenData: Data = NSKeyedArchiver.archivedData(withRootObject: accountToken)
            try? self.keychain.set(tokenData, key: userID!)

            self.setAccount(swifter: swifter,
                            userID: userID!,
                            oauthToken: oauthToken!,
                            oauthSecret: oauthSecret!,
                            failure: failure,
                            notificationName: .login)
        }

        swifter.authorize(withCallback: URL(string: "nowplayingtweet://success")!,
                          forceLogin: true,
                          success: success,
                          failure: failure)
    }

    func logout(account: Account) {
        self.accounts.removeValue(forKey: account.id)
        try? self.keychain.remove(account.id)

        if self.existsAccounts {
            self.updateCurrentAccount()
        }

        self.notificationCenter.post(name: .logout,
                                     object: nil,
                                     userInfo: ["oldUserID" : account.id])
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
        if self.accounts.keys.contains(self.userDefaults.string(forKey: "CurrentAccount") ?? "") {
            return
        }

        if self.existsAccounts {
            let userID = self.accountIDs.first
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

    private func setAccount(swifter: Swifter, userID: String, oauthToken: String, oauthSecret: String, failure: @escaping Swifter.FailureHandler, notificationName: Notification.Name? = nil) {
        /*
        swifter.showUser(.id(userID), success: { json in
            let name = json.object!["name"]?.string
            let screenName = json.object!["screen_name"]?.string
            let avaterUrl = URL(string: (json.object!["profile_image_url_https"]?.string)!)

            let account = Accounts.Account(swifter: swifter,
                                           userID: userID,
                                           oauthToken: oauthToken,
                                           oauthSecret: oauthSecret,
                                           name: name!,
                                           screenName: screenName!,
                                           avaterUrl: avaterUrl!)
            self.accounts[userID] = account

            if notificationName != nil {
                self.notificationCenter.post(name: notificationName!,
                                             object: nil,
                                             userInfo: ["account" : account])
            }
        }, failure: failure)
         */
    }

}
