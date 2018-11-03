/**
 *  NSButton++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

extension NSButton {

    func set(state: Bool) {
        self.state = state ? .on : .off
    }

}
