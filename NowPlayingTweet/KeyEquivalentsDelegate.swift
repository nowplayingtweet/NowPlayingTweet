/**
 *  KeyEquivalentsDelegate.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation

protocol KeyEquivalentsDelegate: NSObjectProtocol {

    func tweet(with userID: String) -> Void

    func tweetWithCurrent() -> Void

}
