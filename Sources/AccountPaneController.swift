/**
 *  AccountPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class AccountPaneController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var providerIcon: NSImageView!
    @IBOutlet weak var provider: NSTextField!
    @IBOutlet weak var avater: NSImageView!
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var screenName: NSTextField!
    @IBOutlet weak var currentButton: NSButton!
    @IBOutlet weak var currentLabel: NSTextField!
    @IBOutlet weak var accountControl: NSSegmentedControl!
    @IBOutlet weak var accountList: NSTableView!

    private let appDelegate: AppDelegate = NSApplication.shared.delegate as! AppDelegate

    static let shared: AccountPaneController = {
        let windowController = NSStoryboard.main!.instantiateController(withIdentifier: .accountPaneController)
        return windowController as! AccountPaneController
    }()

    private var _selected: Account? = nil

    var selected: Account? {
        get {
            return self._selected
        }
        set {
            guard let account = newValue else {
                self.providerIcon.image = nil
                self.providerIcon.isHidden = true
                self.provider.stringValue = "Social Account"

                self.name.stringValue = "Not logged in..."
                self.screenName.isHidden = true
                self.avater.isEnabled = false
                self.avater.image = NSImage(named: "NSUserGuest", templated: true)
                self.accountList.deselectAll(nil)
                self.currentLabel.isHidden = true
                self.currentButton.isHidden = true
                self._selected = nil
                return
            }

            let index = IndexSet(integer: Accounts.shared.sortedAccounts.firstIndex { account.isEqual($0) } ?? 0)
            self.accountList.selectRowIndexes(index, byExtendingSelection: false)

            self.providerIcon.isHidden = false
            self.providerIcon.image = type(of: account).provider.logo
            self.provider.stringValue = String(describing: type(of: account).provider)

            self.name.stringValue = account.name
            self.screenName.isHidden = false
            self.screenName.stringValue = "@\(account.username)"
            self.avater.isEnabled = true
            self.avater.fetchImage(url: account.avaterUrl, rounded: true)

            let isCurrent = account.isEqual(Accounts.shared.current)
            self.currentLabel.isHidden = !isCurrent
            self.currentButton.isHidden = isCurrent

            self._selected = account
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.
        guard let current = Accounts.shared.current else {
            return
        }

        self.selected = current
    }

    @IBAction private func setToCurrent(_ sender: NSButton) {
        guard let selected = self.selected else {
            return
        }

        Accounts.shared.current = selected
        self.currentLabel.isHidden = false
        self.currentButton.isHidden = true

        self.appDelegate.updateSocialAccount()
        self.selected = selected
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
        guard let provider = Provider(rawValue: "Twitter") else {
            return
        }

        let notificationCenter: NotificationCenter = NotificationCenter.default
        var observer: NSObjectProtocol!
        observer = notificationCenter.addObserver(forName: .login, object: nil, queue: nil, using: { notification in
            notificationCenter.removeObserver(observer!)

            guard let selected = notification.userInfo!["account"] as? Account else {
                return
            }

            self.appDelegate.updateSocialAccount()
            self.selected = selected
        })

        Accounts.shared.login(provider: provider)
    }

    private func removeAccount() {
        guard let selected = self.selected else {
            return
        }

        let notificationCenter: NotificationCenter = NotificationCenter.default
        var observer: NSObjectProtocol!
        observer = notificationCenter.addObserver(forName: .logout, object: nil, queue: nil, using: { _ in
            notificationCenter.removeObserver(observer!)

            self.appDelegate.updateSocialAccount()
            self.selected = Accounts.shared.sortedAccounts.first
        })

        Accounts.shared.logout(account: selected)
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        if !Accounts.shared.existsAccounts {
            self.accountControl.setEnabled(false, forSegment: 1)
            return 0
        }
        self.accountControl.setEnabled(true, forSegment: 1)
        let accountCount = Accounts.shared.sortedAccounts.count
        return accountCount
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let selected = Accounts.shared.sortedAccounts[row]
        self.selected = selected

        return true
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! AccountCellView

        let account = Accounts.shared.sortedAccounts[row]

        cellView.textField?.stringValue = account.name
        cellView.screenName?.stringValue = "@\(account.username)"
        cellView.imageView?.fetchImage(url: account.avaterUrl, rounded: true)

        return cellView
    }

}
