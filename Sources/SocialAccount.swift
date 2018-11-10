/**
 *  SocialAccount.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import SwifterMac

struct SocialAccount {

    let providerName: Provider.Name

    let client: SocialClient?

    let oauthToken: String

    let oauthSecret: String?

    let userID: String

    let name: String?

    let screenName: String?

    let avaterUrl: URL?

    var isCurrent: Bool {
        let current = SocialAccounts.shared.current
        return current?.providerName == self.providerName && current?.userID == self.userID
    }

    init(_ providerName: Provider.Name, oauthToken: String, oauthSecret: String?, userID: String, name: String?, screenName: String?, avaterUrl: String?) {
        self.providerName = providerName
        self.oauthToken = oauthToken
        self.oauthSecret = oauthSecret
        self.userID = userID
        self.name = name
        self.screenName = screenName
        self.avaterUrl = URL(string: avaterUrl ?? "")

        switch self.providerName {
          case .twitter:
            self.client = TwitterClient(token: self.oauthToken, secret: self.oauthSecret!)
          default:
            self.client = nil
        }
    }

    func post(_ text: String, image: NSImage? = nil, failure: ((Error) -> Void)? = nil, success: ((Any) -> Void)? = nil) {
        switch self.providerName {
          case .twitter:
            (self.client as? TwitterClient)?.post(text, with: image, failure: failure) { json in
                success?(json)
            }
          default:
            break
        }
    }

    func updateProfile(failure: ((Error) -> Void)? = nil, success: @escaping (SocialAccount) -> Void) {
        (self.client as? TwitterClient)?.profile(account: self, failure: failure) { json in
            let name = json.object!["name"]?.string
            let screenName = json.object!["screen_name"]?.string
            let avaterUrl = json.object?["profile_image_url_https"]?.string

            success(self.set(name: name, screenName: screenName, avaterUrl: avaterUrl))
        }
    }

    func set(name: String? = nil, screenName: String? = nil, avaterUrl: String? = nil) -> SocialAccount {
        let newName: String? = name ?? self.name
        let newScreenName: String? = screenName ?? self.screenName
        let newAvater: String? = avaterUrl ?? self.avaterUrl?.absoluteString
        let accountsKeychain = SocialAccounts.shared.keychain
        try? accountsKeychain.remove(self.userID)
        let account: [String:String] = ["providerName" : self.providerName.rawValue,
                                        "oauthToken" : self.oauthToken,
                                        "oauthSecret" : self.oauthSecret ?? "",
                                        "userID" : self.userID,
                                        "name" : newName ?? "",
                                        "screenName" : newScreenName ?? "",
                                        "avaterUrl" : newAvater ?? ""]
        let accountData: Data = NSKeyedArchiver.archivedData(withRootObject: account)
        try? accountsKeychain.set(accountData, key: self.providerName.rawValue + "-" + self.userID)

        return SocialAccount(self.providerName,
                             oauthToken: self.oauthToken,
                             oauthSecret: self.oauthSecret,
                             userID: self.userID,
                             name: newName,
                             screenName: newScreenName,
                             avaterUrl: newAvater)
    }

}
