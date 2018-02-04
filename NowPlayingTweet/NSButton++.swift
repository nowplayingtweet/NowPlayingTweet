/**
 *  NSButton++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import AppKit

extension NSButton {

    func set(state: Bool) {
        self.state = state ? .on : .off
    }

}
