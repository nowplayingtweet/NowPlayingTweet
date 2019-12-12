/**
 *  NSGridView++.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Cocoa

extension NSGridView {

    func removeRowWithView(at index: Int) {
        let row = self.row(at: index)
        for cellIndex in 0..<row.numberOfCells {
            row.cell(at: cellIndex).contentView?.removeFromSuperview()
        }
        self.removeRow(at: index)
    }

}
