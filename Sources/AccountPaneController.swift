/**
 *  AccountPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class AccountPaneController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    static let shared: AccountPaneController = {
        let windowController = NSStoryboard.main!.instantiateController(withIdentifier: .accountPaneController)
        return windowController as! AccountPaneController
    }()

    private let appDelegate = NSApplication.shared.delegate as! AppDelegate

    private let accounts = Accounts.shared

    @IBOutlet weak var accountList: NSTableView!
    @IBOutlet weak var accountControl: NSSegmentedControl!
    @IBOutlet weak var accountBox: NSBox!

    @IBOutlet var providerView: NSScrollView!
    // providerView subview
    @IBOutlet weak var providerList: NSTableView!

    @IBOutlet var accountView: NSView!
    // accountView subviews
    @IBOutlet weak var providerIcon: NSImageView!
    @IBOutlet weak var provider: NSTextField!
    @IBOutlet weak var avater: NSImageView!
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var screenName: NSTextField!
    @IBOutlet weak var currentButton: NSButton!
    @IBOutlet weak var currentLabel: NSTextField!

    private var _selected: Account?

    var selected: Account? {
        get {
            return self._selected
        }
        set {
            guard let account = newValue else {
                self.accountBox.contentView = self.providerView
                self._selected = nil
                self.accountControl.setEnabled(false, forSegment: 0)
                self.accountControl.setEnabled(false, forSegment: 1)
                self.accountList.deselectAll(nil)
                return
            }

            self.accountBox.contentView = self.accountView
            self._selected = account
            self.accountControl.setEnabled(true, forSegment: 0)
            self.accountControl.setEnabled(true, forSegment: 1)

            if let account = account as? D14nAccount {
                self.screenName.stringValue = "@\(account.username)@\(account.domain)"
            } else {
                self.screenName.stringValue = "@\(account.username)"
            }

            self.providerIcon.image = type(of: account).provider.icon
            self.provider.stringValue = String(describing: type(of: account).provider)

            self.name.stringValue = account.name
            self.avater.fetchImage(url: account.avaterUrl, rounded: true)

            let isCurrent = account.isEqual(self.accounts.current)
            self.currentLabel.isHidden = !isCurrent
            self.currentButton.isHidden = isCurrent
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.
        self.accountBox.contentView = self.providerView
    }

    @IBAction private func setToCurrent(_ sender: NSButton) {
        guard let selected = self.selected else {
            return
        }

        self.accounts.current = selected
        self.appDelegate.updateSocialAccount()
    }

    @IBAction func manageAccount(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
          case 0:
            self.selected = nil
          case 1:
            self.removeAccount()
          default: // 2
            break
        }
    }

    private func addAccount(_ provider: Provider) {
        let notificationCenter: NotificationCenter = NotificationCenter.default
        var observer: NSObjectProtocol!
        observer = notificationCenter.addObserver(forName: .login, object: nil, queue: nil, using: { notification in
            notificationCenter.removeObserver(observer!)

            guard let selected = notification.userInfo!["account"] as? Account else {
                return
            }

            self.selected = selected
            self.appDelegate.updateSocialAccount()
        })

        self.accounts.login(provider: provider)
    }

    private func removeAccount() {
        guard let selected = self.selected else {
            return
        }

        let notificationCenter: NotificationCenter = NotificationCenter.default
        var observer: NSObjectProtocol!
        observer = notificationCenter.addObserver(forName: .logout, object: nil, queue: nil, using: { _ in
            notificationCenter.removeObserver(observer!)

            self.selected = nil
            self.appDelegate.updateSocialAccount()
        })

        self.accounts.logout(account: selected)
    }

    func accountReload() {
        self.accountList.reloadData()

        if let selected = self.selected {
            let index = IndexSet(integer: self.accounts.sortedAccounts.firstIndex { selected.isEqual($0) }!)
            self.accountList.selectRowIndexes(index, byExtendingSelection: false)
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView {
        case self.accountList:
            return self.accounts.sortedAccounts.count
        case self.providerList:
            return self.accounts.availableProviders.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        switch tableView {
        case self.accountList:
            return self.accounts.sortedAccounts[row]
        case self.providerList:
            return self.accounts.availableProviders[row]
        default:
            return nil
        }
    }

    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        switch tableView {
        case self.accountList:
            return tableView.clickedRow >= 0 || self.selected == nil
        default:
            return true
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else {
            return
        }

        switch tableView {
        case self.accountList:
            if tableView.selectedRow >= 0 {
                self.selected = self.accounts.sortedAccounts[tableView.selectedRow]
            }
        case self.providerList:
            if tableView.selectedRow >= 0 {
                self.addAccount(self.accounts.availableProviders[tableView.selectedRow])
                tableView.reloadData()
            }
        default: break
        }
    }

}
