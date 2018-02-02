/**
 *  TwitterAccount.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import SwifterMac
import KeychainAccess

class TwitterAccount: NSObject, NSUserNotificationCenterDelegate {

    var swifter: Swifter?

    private var consumerKey: String = "lT580cWIob4JiEmydWrz3Lr3c"
    private var consumerSecret: String = "tQbaxDRMSNebagQaa9RXtjQ9SskoNiwo8bBadP2y6aggFesDik"
    private var oauthToken: String?
    private var oauthSecret: String?
    private var userID: String?
    private var screenName: String?

    let keychain = Keychain(service: "com.kr-kp.NowPlayingTweet")

    let notificationCenter: NotificationCenter = NotificationCenter.default

    private let failureHandler: Swifter.FailureHandler = { error in
        NSLog(error.localizedDescription)
    }

    override init() {
        super.init()
        self.oauthToken = try! self.keychain.getString("accountToken")
        self.oauthSecret = try! self.keychain.getString("accountSecret")
        if loginCheck() {
            self.swifter = Swifter(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret, oauthToken: self.oauthToken!, oauthTokenSecret: self.oauthSecret!)
            self.swifter?.getAccountSettings(success: { json in
                self.screenName = json.object!["screen_name"]?.string
            }, failure: self.failureHandler)
        } else {
            self.swifter = Swifter(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret)
        }
    }

    func loginCheck() -> Bool {
        return (self.oauthToken != nil && self.oauthSecret != nil)
    }

    func login() {
        let authHandler: Swifter.TokenSuccessHandler = { accessToken, response in
            self.oauthToken = accessToken?.key
            self.oauthSecret = accessToken?.secret
            self.userID = accessToken?.userID
            self.screenName = accessToken?.screenName

            self.keychain["accountToken"] = self.oauthToken
            self.keychain["accountSecret"] = self.oauthSecret

            self.notificationCenter.post(name: .login, object: nil)
        }

        self.swifter?.authorizeForceLogin(with: URL(string: "nowplayingtweet://success")!, success: authHandler, failure: self.failureHandler)
    }

    func logout() {
        self.oauthToken = nil
        self.oauthSecret = nil
        self.userID = nil
        self.screenName = nil
        
        try? self.keychain.remove("accountToken")
        try? self.keychain.remove("accountSecret")
        self.swifter = Swifter(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret)
    }

    func getScreenName() -> String? {
        return "@\((self.screenName)!)"
    }

    @objc func notify(notification: Notification) {
        let info = notification.userInfo as! [String:String]
        
        print(info["title"]!)
        print(info["account name"]!)
    }

}
