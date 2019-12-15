/**
 *  Notification++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation

extension Notification.Name {

    static let login = Notification.Name("com.kr-kp.NowPlayingTweet.login")
    static let logout = Notification.Name("com.kr-kp.NowPlayingTweet.logout")

    static let disableAutoPost = Notification.Name("com.kr-kp.NowPlayingTweet.disableAutoPost")

    static let initializeAccounts = Notification.Name("com.kr-kp.NowPlayingTweet.initializeAccounts")
    static let alreadyAccounts = Notification.Name("com.kr-kp.NowPlayingTweet.alreadyAccounts")

    static let iTunesPlayerInfo = Notification.Name("com.apple.iTunes.playerInfo")

}
