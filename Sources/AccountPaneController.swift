/**
 *  AccountPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import SwifterMac

class AccountPaneController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var avater: NSImageView!
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var screenName: NSTextField!
    @IBOutlet weak var currentButton: NSButton!
    @IBOutlet weak var currentLabel: NSTextField!
    @IBOutlet weak var accountControl: NSSegmentedControl!
    @IBOutlet weak var accountList: NSTableView!

    private let appDelegate: AppDelegate = NSApplication.shared.delegate as! AppDelegate

    private let userDefaults: UserDefaults = UserDefaults.standard

    static let shared: AccountPaneController = {
        let storyboard = NSStoryboard(name: .main, bundle: .main)
        let windowController = storyboard.instantiateController(withIdentifier: .accountPaneController)
        return windowController as! AccountPaneController
    }()

    let twitterClient: TwitterClient = TwitterClient.shared

    var selected: TwitterClient.Account?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.
        guard let current: TwitterClient.Account = self.twitterClient.current else {
            self.set(name: nil)
            self.set(screenName: nil)
            self.set(avaterUrl: nil)
            return
        }

        self.selected = current
        self.accountControl.setEnabled(true, forSegment: 1)

        let numberOfAccounts = self.twitterClient.accountIDs.firstIndex(of: current.userID)!
        let index = IndexSet(integer: numberOfAccounts)
        self.accountList.selectRowIndexes(index, byExtendingSelection: false)

        self.currentLabel.isHidden = false
        self.currentButton.isHidden = false
        self.currentButton.isEnabled = false

        self.set(name: current.name)
        self.set(screenName: current.screenName)
        self.set(avaterUrl: current.avaterUrl)
    }

    @IBAction private func setToCurrent(_ sender: NSButton) {
        let selected = self.selected!
        self.twitterClient.changeCurrent(userID: selected.userID)
        self.appDelegate.updateTwitterAccount()
        self.currentLabel.isHidden = false
        self.currentButton.isEnabled = false
    }

    @IBAction func manageAccount(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
          case 0:
            self.addAccount()
          case 1:
            self.removeAccount()
          default: // 2
            break
        }
    }

    private func addAccount() {
        let notificationCenter: NotificationCenter = NotificationCenter.default
        var observer: NSObjectProtocol!
        observer = notificationCenter.addObserver(forName: .login, object: nil, queue: nil, using: { notification in
            guard let selected: TwitterClient.Account = notification.userInfo!["account"] as? TwitterClient.Account else {
                notificationCenter.removeObserver(observer)
                return
            }

            self.selected = selected

            self.accountList.reloadData()

            let numberOfAccounts = self.twitterClient.accountIDs.firstIndex(of: selected.userID)!
            let index = IndexSet(integer: numberOfAccounts)
            self.accountList.selectRowIndexes(index, byExtendingSelection: false)

            self.appDelegate.updateTwitterAccount()

            let isCurrent = selected.isCurrent
            if isCurrent {
                self.accountControl.setEnabled(true, forSegment: 1)
                self.currentButton.isHidden = false
            }

            self.currentLabel.isHidden = !isCurrent
            self.currentButton.isEnabled = !isCurrent

            self.set(name: selected.name)
            self.set(screenName: selected.screenName)
            self.set(avaterUrl: selected.avaterUrl)

            notificationCenter.removeObserver(observer)
        })

        self.twitterClient.login()
    }

    private func removeAccount() {
        self.twitterClient.logout(account: self.selected!)

        self.accountList.reloadData()
        self.appDelegate.updateTwitterAccount()

        guard let selected = self.twitterClient.current else {
            self.accountControl.setEnabled(false, forSegment: 1)
            self.selected = nil
            self.set(name: nil)
            self.set(avaterUrl: nil)
            self.set(screenName: nil)

            self.currentLabel.isHidden = true
            self.currentButton.isHidden = true

            return
        }

        self.selected = selected

        let numberOfAccounts = self.twitterClient.accountIDs.firstIndex(of: selected.userID)!
        let index = IndexSet(integer: numberOfAccounts)
        self.accountList.selectRowIndexes(index, byExtendingSelection: false)

        let isCurrent = selected.isCurrent
        self.currentLabel.isHidden = !isCurrent
        self.currentButton.isEnabled = !isCurrent

        self.set(name: selected.name)
        self.set(screenName: selected.screenName)
        self.set(avaterUrl: selected.avaterUrl)
    }

    @IBAction private func selectAccount(_ sender: NSTableView) {
        let row = sender.selectedRow

        guard let selected = self.twitterClient.account(userID: self.twitterClient.accountIDs[row]) else {
            return
        }

        self.selected = selected

        let isCurrent = selected.isCurrent
        self.currentLabel.isHidden = !isCurrent
        self.currentButton.isEnabled = !isCurrent
        self.set(name: selected.name)
        self.set(screenName: selected.screenName)
        self.set(avaterUrl: selected.avaterUrl)
    }

    private func set(name: String?) {
        self.name.stringValue = name ?? "Not logged in..."
        self.name.textColor = name != nil ? .labelColor : .disabledControlTextColor
    }

    private func set(screenName id: String?) {
        self.screenName.stringValue = "@" + (id ?? "null")
        self.screenName.textColor = id != nil ? .secondaryLabelColor : .disabledControlTextColor
    }

    private func set(avaterUrl url: URL?) {
        if url != nil {
            self.avater.fetchImage(url: url!, rounded: true)
            self.avater.enable()
        } else {
            self.avater.image = NSImage(named: "NSUserGuest", templated: true)
            self.avater.disable()
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        if !self.twitterClient.existAccount {
            return 0
        }
        let accountCount = self.twitterClient.numberOfAccounts
        return accountCount
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! AccountCellView

        let twitterAccount = self.twitterClient.account(userID: self.twitterClient.accountIDs[row])!

        cellView.textField?.stringValue = twitterAccount.name
        cellView.screenName.stringValue = "@" + twitterAccount.screenName
        cellView.imageView?.fetchImage(url: twitterAccount.avaterUrl, rounded: true)

        return cellView
    }

}
