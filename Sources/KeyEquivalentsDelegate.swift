/**
 *  KeyEquivalentsDelegate.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation

protocol KeyEquivalentsDelegate: NSObjectProtocol {

    func postWithCurrent()

    func post(with: String, of: Provider)

}
