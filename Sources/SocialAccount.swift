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

    init(_ providerName: Provider.Name, oauthToken: String, oauthSecret: String?, userID: String, name: String?, screenName: String?, avaterUrl: String = "") {
        self.providerName = providerName
        self.oauthToken = oauthToken
        self.oauthSecret = oauthSecret
        self.userID = userID
        self.name = name
        self.screenName = screenName
        self.avaterUrl = URL(string: avaterUrl)

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
            (self.client as! TwitterClient).tweet(text, with: image, failure: failure) { json in
                success?(json)
            }
          default:
            break
        }
    }

}
