/**
 *  TwitterClient.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import SwifterMac
import KeychainAccess

class TwitterClient {

    static let shared: TwitterClient = TwitterClient()

    let consumerKey: String = "lT580cWIob4JiEmydWrz3Lr3c"
    let consumerSecret: String = "tQbaxDRMSNebagQaa9RXtjQ9SskoNiwo8bBadP2y6aggFesDik"

    let keychain = Keychain(service: "com.kr-kp.NowPlayingTweet.AccountToken")

    let notificationCenter: NotificationCenter = NotificationCenter.default

    var userDefaults: UserDefaults = UserDefaults.standard

    var accounts: [String : TwitterAccount] = [:]

    var accountIDs: [String] {
        return self.accounts.keys.sorted()
    }

    var existAccount: Bool {
        return self.accounts.count > 0
    }

    var current: TwitterAccount? {
        if !self.existAccount {
            return nil
        }

        let userID = self.currentID
        return self.accounts[userID!]
    }

    var currentID: String? {
        if !self.existAccount {
            return nil
        }

        if !self.accounts.keys.contains(self.userDefaults.string(forKey: "CurrentAccount") ?? "") {
            let userID = self.accountIDs.first
            self.changeCurrent(userID: userID!)
        }

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
        observer = self.notificationCenter.addObserver(forName: .initAccounts, object: nil, queue: nil, using: { notification in
            numOfAccounts -= 1
            if numOfAccounts == 0 {
                self.notificationCenter.post(name: .alreadyAccounts, object: nil)

                if !self.accounts.keys.contains(self.userDefaults.string(forKey: "CurrentAccount") ?? "") {
                    let userID = self.accountIDs.first
                    self.changeCurrent(userID: userID!)
                }

                self.notificationCenter.removeObserver(observer)
            }
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
                            notificationName: .initAccounts)
        }
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

    func logout(account: TwitterAccount) {
        self.accounts.removeValue(forKey: account.userID)
        try? self.keychain.remove(account.userID)

        let currentUserID = self.userDefaults.string(forKey: "CurrentAccount")
        if account.userID == currentUserID! {
            let userID = self.accountIDs.first
            self.changeCurrent(userID: userID!)
        }
    }

    func changeCurrent(userID: String) {
        self.userDefaults.set(userID, forKey: "CurrentAccount")
        self.userDefaults.synchronize()
    }

    private func setAccount(swifter: Swifter,
                            userID: String,
                            oauthToken: String,
                            oauthSecret: String,
                            failure: @escaping Swifter.FailureHandler,
                            notificationName: Notification.Name? = nil) {
        swifter.showUser(for: .id(userID), success: { json in
            let name = json.object!["name"]?.string
            let screenName = json.object!["screen_name"]?.string
            let avaterUrl = URL(string: (json.object!["profile_image_url_https"]?.string)!)

            let account = TwitterAccount(swifter: swifter,
                                         userID: userID,
                                         oauthToken: oauthToken,
                                         oauthSecret: oauthSecret,
                                         name: name!,
                                         screenName: screenName!,
                                         avaterUrl: avaterUrl!)
            self.accounts[userID] = account

            if notificationName != nil {
                self.notificationCenter.post(name: notificationName!, object: nil, userInfo: ["account" : account])
            }
        }, failure: failure)
    }

}
