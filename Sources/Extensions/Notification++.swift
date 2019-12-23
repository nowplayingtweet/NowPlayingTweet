/**
 *  Notification++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation

extension Notification.Name {

    static let login = Notification.Name("com.kr-kp.NowPlayingTweet.login")
    static let authorize = Notification.Name("com.kr-kp.NowPlayingTweet.authorize")

    static let logout = Notification.Name("com.kr-kp.NowPlayingTweet.logout")

    static let disableAutoPost = Notification.Name("com.kr-kp.NowPlayingTweet.disableAutoPost")

    static let alreadyAccounts = Notification.Name("com.kr-kp.NowPlayingTweet.alreadyAccounts")

    static let iTunesPlayerInfo = Notification.Name("com.apple.iTunes.playerInfo")

}
