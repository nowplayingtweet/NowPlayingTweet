/**
 *  NSAlert++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
 **/

import Foundation
import AppKit

extension NSAlert {

    convenience init(message: String, informative: String? = nil, style: NSAlert.Style = .critical) {
        self.init()
        self.messageText = message
        self.alertStyle = style
        if informative != nil {
            self.informativeText = informative!
        }
    }

}

