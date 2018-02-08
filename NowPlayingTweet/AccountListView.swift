//
//  AccountListView.swift
//  NowPlayingTweet
//
//  Created by kPherox on 2018/02/08.
//  Copyright © 2018 kPherox. All rights reserved.
//

import Cocoa

class AccountListView: NSTableView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    override func drawGrid(inClipRect clipRect: NSRect) {
        let lastRowRect: NSRect = self.rect(ofRow: self.numberOfRows - 1)
        let tempClipRect: NSRect = NSMakeRect(0, 0, lastRowRect.size.width, NSMaxY(lastRowRect))
        let finalClipRect: NSRect = NSIntersectionRect(clipRect, tempClipRect)
        super.drawGrid(inClipRect: finalClipRect)
    }

}
