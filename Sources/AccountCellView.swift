/**
 *  AccountCellView.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class AccountCellView: NSTableCellView {

    @IBOutlet weak var currentIndicator: NSImageView!
    @IBOutlet weak var providerName: NSTextField!

    override var objectValue: Any? {
        didSet {
            let objectValue = self.objectValue as AnyObject
            guard let account = objectValue as? Account else {
                return
            }

            if let account = account as? D14nAccount {
                self.providerName.stringValue = account.domain
            } else {
                self.providerName.stringValue = String(describing: type(of: account).provider)
            }

            self.textField?.stringValue = "@\(account.username)"
            self.imageView?.fetchImage(url: account.avaterUrl, rounded: true)
            self.currentIndicator?.isHidden = !account.isEqual(Accounts.shared.current)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

}
