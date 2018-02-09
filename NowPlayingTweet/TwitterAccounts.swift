/**
 *  TwitterAccounts.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import AppKit
import SwifterMac
import KeychainAccess

class TwitterAccounts {

    let consumerKey: String = "lT580cWIob4JiEmydWrz3Lr3c"
    let consumerSecret: String = "tQbaxDRMSNebagQaa9RXtjQ9SskoNiwo8bBadP2y6aggFesDik"

    let keychain = Keychain(service: "com.kr-kp.NowPlayingTweet.AccountToken")

    let notificationCenter: NotificationCenter = NotificationCenter.default

    var userDefaults: UserDefaults = UserDefaults.standard

    var list: [String : TwitterAccount] = [:]
    var listKeys: [String] {
        get {
            return self.list.keys.sorted()
        }
    }

    var existAccount: Bool {
        get {
            return self.list.count > 0
        }
    }

    var current: TwitterAccount? {
        get {
            if !self.existAccount {
                return nil
            }
            let currentUserID = self.userDefaults.string(forKey: "CurrentAccount")
            if self.list.keys.contains(currentUserID!) {
                return self.list[currentUserID!]
            } else {
                let userID = self.listKeys.first
                return self.list[userID!]
            }
        }
    }

    init() {
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

                let currentUserID = self.userDefaults.string(forKey: "CurrentAccount")
                if !self.list.keys.contains(currentUserID!) {
                    let userID = self.listKeys.first
                    self.userDefaults.set(userID, forKey: "CurrentAccount")
                    self.userDefaults.synchronize()
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
        self.list.removeValue(forKey: account.userID)
        try? self.keychain.remove(account.userID)

        let currentUserID = self.userDefaults.string(forKey: "CurrentAccount")
        if account.userID == currentUserID! {
            let userID = self.listKeys.first
            self.userDefaults.set(userID, forKey: "CurrentAccount")
            self.userDefaults.synchronize()
        }
    }

    private func setAccount(swifter: Swifter, userID: String, oauthToken: String, oauthSecret: String, failure: @escaping Swifter.FailureHandler, notificationName: Notification.Name? = nil) {
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
            self.list[userID] = account

            if notificationName != nil {
                self.notificationCenter.post(name: notificationName!, object: nil, userInfo: ["account" : account])
            }
        }, failure: failure)
    }

}
