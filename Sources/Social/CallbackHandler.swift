/**
 *  CallbackHandler.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol CallbackHandler {
    static func handleCallback(_: NSAppleEventDescriptor)
}
