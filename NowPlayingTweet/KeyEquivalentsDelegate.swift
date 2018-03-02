/**
 *  KeyEquivalentsDelegate.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation

protocol KeyEquivalentsDelegate: NSObjectProtocol {

    func tweetWithCurrent() -> Void

    func tweet(with userID: String) -> Void

}
