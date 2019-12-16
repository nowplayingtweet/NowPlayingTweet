/**
 *  NSControl++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

extension NSControl.StateValue {
    
    func toBool() -> Bool {
        if self == .off {
            return false
        }
        
        // Is state on/mixed
        return true
    }
    
}
