/**
 *  KeyEquivalentsDelegate.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation

protocol KeyEquivalentsDelegate: NSObjectProtocol {

    func postWithCurrent() -> Void

    func post(with userID: String, by: Provider.Name) -> Void

}
