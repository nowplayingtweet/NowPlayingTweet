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

    func stateToBool() -> Bool {
        if self.state == .off {
            return false
        }

        // Is state on/mixed
        return true
    }

    func enable() {
        self.isEnabled = true
    }

    func disable() {
        self.isEnabled = false
    }

}
