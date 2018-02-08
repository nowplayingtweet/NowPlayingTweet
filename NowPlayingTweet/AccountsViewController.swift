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

    let appDelegate = NSApplication.shared.delegate as! AppDelegate

    var twitterAccounts: TwitterAccounts?
    var selected: TwitterAccount?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.

        self.twitterAccounts = self.appDelegate.twitterAccounts

        guard self.twitterAccounts!.existAccount else {
            return
        }

        let twitterAccount = self.twitterAccounts?.accounts.first?.value
        self.addButton.disable()
        self.removeButton.enable()
        self.set(screenName: twitterAccount?.screenName)
        self.set(avater: twitterAccount?.avaterUrl)
    }

    @IBAction func addAccount(_ sender: NSButton) {
        self.twitterAccounts?.login()

        let notificationCenter: NotificationCenter = NotificationCenter.default
        var observer: NSObjectProtocol!
        observer = notificationCenter.addObserver(forName: .login, object: nil, queue: nil, using: { notification in
            self.addButton.disable()
            self.removeButton.enable()
            self.selected = notification.userInfo!["account"] as? TwitterAccount
            self.set(screenName: self.selected?.screenName)
            self.set(avater: self.selected?.avaterUrl)
            notificationCenter.removeObserver(observer)
        })
    }

    @IBAction func removeAccount(_ sender: NSButton) {
        self.twitterAccounts?.logout(account: self.selected!)
        self.addButton.enable()
        self.removeButton.disable()

        self.set(avater: nil)
        self.set(screenName: nil)
    }

    func set(screenName string: String?) {
        self.accountName.stringValue = string != nil ? "@\(string!)" : "Account Name"
        self.accountName.textColor = string != nil ? .labelColor : .disabledControlTextColor
    }

    func set(avater url: URL?) {
        if url != nil {
            self.accountAvater.fetchImage(url: url!)
            self.accountAvater.enable()
        } else {
            self.accountAvater.image = NSImage(named: .user)
            self.accountAvater.disable()
        }
    }

}
