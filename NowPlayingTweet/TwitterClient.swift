/**
 *  TwitterClient.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import SwifterMac
import KeychainAccess

class TwitterClient {

    struct Account {
        let swifter: Swifter

        let userID: String

        let oauthToken: String
        let oauthSecret: String

        let name: String

        let screenName: String

        let avaterUrl: URL
    }

    static let shared: TwitterClient = TwitterClient()

    private let consumerKey: String = "lT580cWIob4JiEmydWrz3Lr3c"
    private let consumerSecret: String = "tQbaxDRMSNebagQaa9RXtjQ9SskoNiwo8bBadP2y6aggFesDik"

    private let keychain = Keychain(service: "com.kr-kp.NowPlayingTweet.AccountToken")

    private var userDefaults: UserDefaults = UserDefaults.standard

    private let notificationCenter: NotificationCenter = NotificationCenter.default

    private var accounts: [String : TwitterClient.Account] = [:]

    var accountIDs: [String] {
        return self.accounts.keys.sorted()
    }

    var numberOfAccounts: Int {
        return self.accounts.count
    }

    var existAccount: Bool {
        return self.numberOfAccounts > 0
    }

    var current: TwitterClient.Account? {
        if !self.existAccount {
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
            if numOfAccounts != 0 {
                return
            }

            self.updateCurrentAccount()

            self.notificationCenter.post(name: .alreadyAccounts,
                                         object: nil)
            self.notificationCenter.removeObserver(observer)
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

    func account(name: String) -> TwitterClient.Account? {
        return self.accounts.first { $0.value.name == name }?.value
    }

    func account(screenName: String) -> TwitterClient.Account? {
        return self.accounts.first { $0.value.screenName == screenName }?.value
    }

    func account(userID: String) -> TwitterClient.Account? {
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

        swifter.authorize(with: URL(string: "npt://success")!,
                          forceLogin: true,
                          success: success,
                          failure: failure)
    }

    func logout(account: TwitterClient.Account) {
        self.accounts.removeValue(forKey: account.userID)
        try? self.keychain.remove(account.userID)

        if self.existAccount {
            self.updateCurrentAccount()
        }

        self.notificationCenter.post(name: .logout,
                                     object: nil,
                                     userInfo: ["oldUserID" : account.userID])
    }

    func tweet(account: TwitterClient.Account, text: String, with artwork: NSImage? = nil, success: Swifter.SuccessHandler? = nil, failure: Swifter.FailureHandler? = nil) {
        if artwork == nil {
            account.swifter.postTweet(status: text, success: success, failure: failure)
            return
        }
        let image = artwork?.toData(from: .jpeg)
        account.swifter.postTweet(status: text, media: image!, success: success, failure: failure)
    }

    private func updateCurrentAccount() {
        if self.accounts.keys.contains(self.userDefaults.string(forKey: "CurrentAccount") ?? "") {
            return
        }

        if self.existAccount {
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
        swifter.showUser(for: .id(userID), success: { json in
            let name = json.object!["name"]?.string
            let screenName = json.object!["screen_name"]?.string
            let avaterUrl = URL(string: (json.object!["profile_image_url_https"]?.string)!)

            let account = TwitterClient.Account(swifter: swifter,
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
    }

}
