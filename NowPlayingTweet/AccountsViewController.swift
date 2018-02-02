/**
 *  AccountsViewController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import SwifterMac

class AccountsViewController: NSViewController, NSTableViewDataSource {

    @IBOutlet weak var accountAvater: NSImageView!
    @IBOutlet weak var accountName: NSTextField!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    
    let twitterAccount = (NSApplication.shared.delegate as! AppDelegate).twitterAccount

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.

        if self.twitterAccount.loginCheck() {
            self.addButton.disable()
            self.removeButton.enable()
            self.accountName.stringValue = self.twitterAccount.getScreenName()!
        }
    }

    @IBAction func addAccount(_ sender: NSButton) {
        self.twitterAccount.login()
        self.addButton.disable()
        self.removeButton.enable()
        
        let notificationCenter: NotificationCenter = NotificationCenter.default
        var observer: NSObjectProtocol!
        observer = notificationCenter.addObserver(forName: .login, object: nil, queue: nil, using: { _ in
            self.accountName.stringValue = self.twitterAccount.getScreenName()!
            notificationCenter.removeObserver(observer)
        })
    }

    @IBAction func removeAccount(_ sender: NSButton) {
        self.twitterAccount.logout()
        self.addButton.enable()
        self.removeButton.disable()

        self.accountName.stringValue = "Account Name"
    }

}
