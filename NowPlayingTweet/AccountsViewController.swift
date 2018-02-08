/**
 *  AccountsViewController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import SwifterMac

class AccountsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var accountAvater: NSImageView!
    @IBOutlet weak var accountName: NSTextField!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!

    let appDelegate = NSApplication.shared.delegate as! AppDelegate

    var twitterAccounts: TwitterAccounts {
        get {
            return self.appDelegate.twitterAccounts
        }
    }
    var selected: TwitterAccount?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.
        guard self.twitterAccounts.existAccount else {
            return
        }

        self.selected = self.twitterAccounts.accounts.first?.value
        self.addButton.disable()
        self.removeButton.enable()
        self.set(screenName: self.selected?.screenName)
        self.set(avaterUrl: self.selected?.avaterUrl)
    }

    @IBAction func addAccount(_ sender: NSButton) {
        self.twitterAccounts.login()

        let notificationCenter: NotificationCenter = NotificationCenter.default
        var observer: NSObjectProtocol!
        observer = notificationCenter.addObserver(forName: .login, object: nil, queue: nil, using: { notification in
            self.addButton.disable()
            self.removeButton.enable()
            self.selected = notification.userInfo!["account"] as? TwitterAccount
            self.set(screenName: self.selected?.screenName)
            self.set(avaterUrl: self.selected?.avaterUrl)
            notificationCenter.removeObserver(observer)
        })
    }

    @IBAction func removeAccount(_ sender: NSButton) {
        self.twitterAccounts.logout(account: self.selected!)
        self.addButton.enable()
        self.removeButton.disable()

        self.set(avaterUrl: nil)
        self.set(screenName: nil)
    }

    func set(screenName string: String?) {
        self.accountName.stringValue = string != nil ? "@\(string!)" : "Account Name"
        self.accountName.textColor = string != nil ? .labelColor : .disabledControlTextColor
    }

    func set(avaterUrl url: URL?) {
        if url != nil {
            self.accountAvater.fetchImage(url: url!)
            self.accountAvater.enable()
        } else {
            self.accountAvater.image = NSImage(named: .user)
            self.accountAvater.disable()
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        guard self.twitterAccounts.existAccount else {
            return 0
        }
        let accountCount = self.twitterAccounts.accounts.count
        return accountCount
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView

        let userID = self.twitterAccounts.keys[row]
        let twitterAccount: TwitterAccount = self.twitterAccounts.accounts[userID]!

        cellView.textField!.stringValue = twitterAccount.screenName
        cellView.imageView?.image = NSImage(named: .user)
        cellView.imageView?.fetchImage(url: twitterAccount.avaterUrl)

        return cellView
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return CGFloat(35)
    }

}
