/**
 *  Label.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class Label: NSTextField {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(with labelString: String, frame frameRect: NSRect, alignment: NSTextAlignment) {
        super.init(frame: frameRect)
        self.stringValue = labelString
        self.alignment = .right
        self.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        self.textColor = .labelColor
        self.drawsBackground = false
        self.isBordered = false
        self.isEditable = false
        self.isSelectable = false
    }

}
