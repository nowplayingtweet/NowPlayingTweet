/**
 *  AccountsViewController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import SwifterMac

class AccountsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var avater: NSImageView!
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var screenName: NSTextField!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    @IBOutlet weak var accountList: AccountsListView!

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
        if !self.twitterAccounts.existAccount {
            return
        }

        self.selected = self.twitterAccounts.current
        self.removeButton.enable()
        self.set(name: self.selected?.name)
        self.set(screenName: self.selected?.screenName)
        self.set(avaterUrl: self.selected?.avaterUrl)
        let userID = self.selected?.userID
        let numberOfAccounts = self.twitterAccounts.listKeys.index(of: userID!)!
        let index = IndexSet(integer: numberOfAccounts)
        self.accountList.selectRowIndexes(index, byExtendingSelection: false)
    }

    @IBAction func addAccount(_ sender: NSButton) {
        self.twitterAccounts.login()

        let notificationCenter: NotificationCenter = NotificationCenter.default
        var observer: NSObjectProtocol!
        observer = notificationCenter.addObserver(forName: .login, object: nil, queue: nil, using: { notification in
            self.removeButton.enable()
            self.selected = notification.userInfo!["account"] as? TwitterAccount

            self.accountList.reloadData()

            let userID = self.selected?.userID
            let name = self.selected?.name

            let numberOfAccounts = self.twitterAccounts.listKeys.index(of: userID!)!
            let index = IndexSet(integer: numberOfAccounts)
            self.accountList.selectRowIndexes(index, byExtendingSelection: false)

            let menuItem = NSMenuItem()
            menuItem.title = name!
            menuItem.action = #selector(self.appDelegate.tweetBySelectingAccount(_:))

            if self.twitterAccounts.listKeys.count == 1 {
                let menu = NSMenu()
                menu.addItem(menuItem)
                self.appDelegate.tweetMenu?.submenu = menu
                self.appDelegate.updateCurrentAccount(to: true)
            } else {
                self.appDelegate.tweetMenu?.submenu?.insertItem(menuItem, at: numberOfAccounts)
            }

            self.set(name: name)
            self.set(screenName: self.selected?.screenName)
            self.set(avaterUrl: self.selected?.avaterUrl)

            notificationCenter.removeObserver(observer)
        })
    }

    @IBAction func removeAccount(_ sender: NSButton) {
        self.twitterAccounts.logout(account: self.selected!)

        self.accountList.reloadData()

        if self.twitterAccounts.existAccount {
            let removedName = self.selected?.name
            let menuItem = self.appDelegate.tweetMenu?.submenu?.item(withTitle: removedName!)
            self.appDelegate.tweetMenu?.submenu?.removeItem(menuItem!)

            self.selected = self.twitterAccounts.current

            let userID = self.selected?.userID
            let numberOfAccounts = self.twitterAccounts.listKeys.index(of: userID!)!
            let index = IndexSet(integer: numberOfAccounts)
            self.accountList.selectRowIndexes(index, byExtendingSelection: false)

            self.set(name: self.selected?.name)
            self.set(screenName: self.selected?.screenName)
            self.set(avaterUrl: self.selected?.avaterUrl)
        } else {
            self.appDelegate.tweetMenu?.submenu = nil
            self.appDelegate.updateCurrentAccount(to: false)

            self.removeButton.disable()
            self.selected = nil
            self.set(name: nil)
            self.set(avaterUrl: nil)
            self.set(screenName: nil)
        }
    }

    @IBAction func selectAccount(_ sender: AccountsListView) {
        let row = sender.selectedRow
        let userID = self.twitterAccounts.listKeys[row]
        let twitterAccount: TwitterAccount = self.twitterAccounts.list[userID]!
        self.selected = twitterAccount

        self.set(name: twitterAccount.name)
        self.set(screenName: twitterAccount.screenName)
        self.set(avaterUrl: twitterAccount.avaterUrl)
    }

    func set(name string: String?) {
        self.name.stringValue = string != nil ? string! : "Account Name"
        self.name.textColor = string != nil ? .labelColor : .disabledControlTextColor
    }

    func set(screenName string: String?) {
        self.screenName.stringValue = "@\(string != nil ? string! : "null")"
        self.screenName.textColor = string != nil ? .secondaryLabelColor : .disabledControlTextColor
    }

    func set(avaterUrl url: URL?) {
        if url != nil {
            self.avater.fetchImage(url: url!, rounded: true)
            self.avater.enable()
        } else {
            self.avater.image = NSImage(named: .user)
            self.avater.disable()
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        if !self.twitterAccounts.existAccount {
            return 0
        }
        let accountCount = self.twitterAccounts.list.count
        return accountCount
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! AccountCellView

        let userID = self.twitterAccounts.listKeys[row]
        let twitterAccount: TwitterAccount = self.twitterAccounts.list[userID]!

        cellView.textField?.stringValue = twitterAccount.name
        cellView.screenName.stringValue = "@\(twitterAccount.screenName)"
        cellView.imageView?.fetchImage(url: twitterAccount.avaterUrl, rounded: true)

        return cellView
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return CGFloat(50)
    }

}
