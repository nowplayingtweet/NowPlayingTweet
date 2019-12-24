/**
 *  AccountPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class AccountPaneController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {

    static let shared: AccountPaneController = {
        let windowController = NSStoryboard.main!.instantiateController(withIdentifier: .accountPaneController)
        return windowController as! AccountPaneController
    }()

    private let appDelegate = NSApplication.shared.delegate as! AppDelegate

    private let accounts = Accounts.shared

    @IBOutlet weak var accountList: NSTableView!
    @IBOutlet weak var accountControl: NSSegmentedControl!
    @IBOutlet weak var accountBox: NSBox!

    // Login Providers
    @IBOutlet var providerView: NSScrollView!

    @IBOutlet weak var providerList: NSTableView!

    // Account Details
    @IBOutlet var accountView: NSView!

    @IBOutlet weak var providerIcon: NSImageView!
    @IBOutlet weak var provider: NSTextField!

    @IBOutlet weak var avater: NSImageView!
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var screenName: NSTextField!

    @IBOutlet weak var currentButton: NSButton!
    @IBOutlet weak var currentLabel: NSTextField!

    @IBOutlet weak var accountSettings: NSGridView!
    @IBOutlet weak var postVisibility: NSPopUpButton!
    @IBOutlet weak var customVisibility: NSTextField!
    @IBOutlet weak var contentWarningButton: NSButton!
    @IBOutlet weak var spoilerText: NSTextField!
    @IBOutlet weak var sensitiveImage: NSButton!

    private var _selected: Account?

    private var selected: Account? {
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
            self.currentButton.isEnabled = !isCurrent

            let accountSetting = UserDefaults.standard.accountSetting(forKey: account.keychainID)

            self.customVisibility.isEnabled = false
            self.customVisibility.stringValue = ""
            let visibility = accountSetting["Visibility"] as! String
            switch visibility {
            case "Default", "Public", "Unlisted", "Private":
                self.postVisibility.selectItem(withTitle: visibility)
            case "":
                self.postVisibility.selectItem(withTitle: "Default")
            default:
                self.postVisibility.selectItem(withTitle: "Custom")
                self.customVisibility.isEnabled = true
                self.customVisibility.stringValue = visibility
            }

            let contentWarning = accountSetting["ContentWarning"] as! [String : Any]
            self.spoilerText.isEnabled = contentWarning["Enabled"] as! Bool
            self.spoilerText.stringValue = self.spoilerText.isEnabled ? contentWarning["SpoilerText"] as! String : ""
            self.contentWarningButton.set(state: self.spoilerText.isEnabled)

            self.sensitiveImage.set(state: accountSetting["SensitiveImage"] as! Bool)

            switch type(of: account).provider {
            case .Mastodon:
                self.accountSettings.isHidden = false
            default:
                self.accountSettings.isHidden = true
                return
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.
        NotificationCenter.default.addObserver(forName: .login, object: nil, queue: .main, using: { notification in
            guard let account = notification.userInfo!["account"] as? Account else {
                return
            }

            self.selected = account
            self.appDelegate.updateSocialAccount()
        })

        NotificationCenter.default.addObserver(forName: .logout, object: nil, queue: .main, using: { _ in
            self.selected = nil
            self.appDelegate.updateSocialAccount()
        })

        self.accountBox.contentView = self.providerView
    }

    @IBAction func changeVisibility(_ sender: NSPopUpButton) {
        self.customVisibility.isEnabled = sender.title == "Custom"

        var setting = UserDefaults.standard.accountSetting(forKey: self.selected!.keychainID)
        setting["Visibility"] = sender.title == "Custom"
            ? self.customVisibility.stringValue
            : sender.title
        UserDefaults.standard.setAccountSetting(setting, forKey: self.selected!.keychainID)
    }

    @IBAction func switchContentWarning(_ sender: NSButton) {
        self.spoilerText.isEnabled = sender.state.toBool()

        var setting = UserDefaults.standard.accountSetting(forKey: self.selected!.keychainID)
        var contentWarning = setting["ContentWarning"] as! [String : Any]
        contentWarning["Enabled"] = sender.state.toBool()
        setting["ContentWarning"] = contentWarning
        UserDefaults.standard.setAccountSetting(setting, forKey: self.selected!.keychainID)
    }

    @IBAction func switchSensitiveImage(_ sender: NSButton) {
        var setting = UserDefaults.standard.accountSetting(forKey: self.selected!.keychainID)
        setting["SensitiveImage"] = sender.state.toBool()
        UserDefaults.standard.setAccountSetting(setting, forKey: self.selected!.keychainID)
    }

    @IBAction func setToCurrent(_ sender: NSButton) {
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
        if (provider.client as? D14nClient.Type) != nil {
            var token: NSObjectProtocol?
            token = NotificationCenter.default.addObserver(forName: .authorize, object: nil, queue: nil, using: { notification in
                defer {
                    NotificationCenter.default.removeObserver(token!)
                }

                guard let base = notification.userInfo!["server_url"] as? String else {
                    return
                }

                self.accounts.login(provider: provider, base: base)
                self.dismiss(AuthorizeSheetController.shared)
            })

            self.presentAsSheet(AuthorizeSheetController.shared)
        } else {
            self.accounts.login(provider: provider)
        }
    }

    private func removeAccount() {
        guard let selected = self.selected else {
            return
        }

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

    func controlTextDidChange(_ notification: Notification) {
        guard let textField = notification.object as? NSTextField else {
            return
        }

        var setting = UserDefaults.standard.accountSetting(forKey: self.selected!.keychainID)

        switch textField {
        case self.customVisibility:
            setting["Visibility"] = self.customVisibility.stringValue
            UserDefaults.standard.setAccountSetting(setting, forKey: self.selected!.keychainID)
        case self.spoilerText:
            var setting = UserDefaults.standard.accountSetting(forKey: self.selected!.keychainID)
            var contentWarning = setting["ContentWarning"] as! [String : Any]
            contentWarning["SpoilerText"] = self.spoilerText.stringValue
            setting["ContentWarning"] = contentWarning
            UserDefaults.standard.setAccountSetting(setting, forKey: self.selected!.keychainID)
        default:
            break
        }
    }

}
