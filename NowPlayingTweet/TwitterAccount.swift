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

class TwitterAccount: NSObject, NSUserNotificationCenterDelegate {

    var swifter: Swifter?

    private var consumerKey: String = "lT580cWIob4JiEmydWrz3Lr3c"
    private var consumerSecret: String = "tQbaxDRMSNebagQaa9RXtjQ9SskoNiwo8bBadP2y6aggFesDik"

    private var accountToken: [String : String?] = ["oauthToken" : nil, "oauthSecret" : nil]

    private var userID: String?
    private var screenName: String?
    private var avaterUrl: URL?

    private(set) var isLogin: Bool = false

    private let notificationCenter: NotificationCenter = NotificationCenter.default

    private let keychain = Keychain(service: "com.kr-kp.NowPlayingTweet.AccountToken")

    private let failureHandler: Swifter.FailureHandler = { error in
        NSLog(error.localizedDescription)
    }

    override init() {
        super.init()

        let accounts = self.keychain.allKeys()

        //for account in accounts {
        if accounts.count > 0 {
            let account = accounts.first!

            let token: Data? = try! self.keychain.getData(account)
            let accountToken: [String : String?] = NSKeyedUnarchiver.unarchiveObject(with: token!) as! [String : String?]
            self.accountToken = accountToken

            self.isLogin = self.loginCheck()

            self.userID = account
            self.accountToken = accountToken
        }

        if self.isLogin {
            self.swifter = Swifter(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret, oauthToken: self.accountToken["oauthToken"]!!, oauthTokenSecret: self.accountToken["oauthSecret"]!!)
            self.fetchProfile()
        } else {
            self.swifter = Swifter(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret)
        }
    }

    private func loginCheck() -> Bool {
        return (self.accountToken["oauthToken"]! != nil && self.accountToken["oauthSecret"]! != nil)
    }

    private func fetchProfile() {
        self.swifter?.showUser(for: .id(self.userID!), success: { json in
            self.screenName = json.object!["screen_name"]?.string
            self.avaterUrl = URL(string: (json.object!["profile_image_url_https"]?.string)!)

            self.notificationCenter.post(name: .login, object: nil)
        }, failure: self.failureHandler)
    }

    func login() {
        let authHandler: Swifter.TokenSuccessHandler = { accessToken, response in
            self.accountToken["oauthToken"] = accessToken?.key
            self.accountToken["oauthSecret"] = accessToken?.secret

            self.isLogin = self.loginCheck()

            self.userID = accessToken?.userID

            self.fetchProfile()

            let accountToken: Data = NSKeyedArchiver.archivedData(withRootObject: self.accountToken)
            try? self.keychain.set(accountToken, key: self.userID!)
        }

        self.swifter?.authorizeForceLogin(with: URL(string: "npt://success")!, success: authHandler, failure: self.failureHandler)
    }

    func logout() {
        self.accountToken = ["oauthToken" : nil, "oauthSecret" : nil]

        try? self.keychain.remove(self.userID!)
        self.userID = nil
        self.screenName = nil
        self.swifter = Swifter(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret)
    }

    func tweet(text: String, with artwork: NSImage? = nil) {
        if artwork == nil {
            self.swifter?.postTweet(status: text)
            return
        }
        let image = artwork?.toData(from: .jpeg)
        self.swifter?.postTweet(status: text, media: image!)
    }

    func getScreenName() -> String? {
        return self.screenName!
    }

    func getAvaterURL() -> URL {
        return self.avaterUrl!
    }

}
