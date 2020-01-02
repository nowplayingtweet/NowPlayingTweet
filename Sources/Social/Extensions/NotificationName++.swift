/**
 *  NotificationName++.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

extension Notification.Name {

    static let socialAccountsInitialize = Notification.Name("dev.kpherox.SocialAccounts.Initialize")

    static let callbackMastodon = Notification.Name("dev.kpherox.SocialAccounts.Callback.Mastodon")

    static let authorizeMastodon = Notification.Name("dev.kpherox.SocialAccounts.Authorize.Mastodon")

}
