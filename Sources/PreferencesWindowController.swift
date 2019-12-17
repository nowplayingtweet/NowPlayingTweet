/**
 *  PreferencesWindowController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class PreferencesWindowController: NSWindowController {

    private let userDefaults = UserDefaults.standard

    private let viewControllers: [NSViewController] = [
        GeneralPaneController.shared,
        AccountPaneController.shared,
        AdvancedPaneController.shared,
        KeyEquivalentsPaneController.shared,
        ]

    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var generalPane: NSToolbarItem!
    @IBOutlet weak var accountPane: NSToolbarItem!
    @IBOutlet weak var advancedPane: NSToolbarItem!
    @IBOutlet weak var keyEquivalentsPane: NSToolbarItem!

    private var lastViewItemIdentifier: String {
        get {
            return self.userDefaults.string(forKey: "lastViewItemIdentifier") ?? ""
        }
        set(newValue) {
            self.userDefaults.set(newValue, forKey: "lastViewItemIdentifier")
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        let items: [NSToolbarItem] = [
            self.generalPane,
            self.accountPane,
            self.advancedPane,
            self.keyEquivalentsPane,
            ]

        let lastViewItemIdentifier = NSToolbarItem.Identifier(self.lastViewItemIdentifier)

        let item: NSToolbarItem = items.first(where: { $0.itemIdentifier == lastViewItemIdentifier }) ?? self.generalPane

        self.toolbar.selectedItemIdentifier = item.itemIdentifier

        self.switchView(item)
        self.window?.center()

        self.window?.level = .floating
    }

    @objc func cancel(_ sender: Any?) {
        self.close()
    }

    @IBAction func switchView(_ toolbarItem: NSToolbarItem) {
        let viewController = self.viewControllers[toolbarItem.tag]

        let windowFrame: NSRect = (self.window?.frame)!
        var newWindowFrame: NSRect = (self.window?.frameRect(forContentRect: viewController.view.frame))!
        newWindowFrame.origin.x = windowFrame.origin.x
        newWindowFrame.origin.y = windowFrame.origin.y + windowFrame.size.height - newWindowFrame.size.height

        self.window?.contentViewController = nil
        self.window?.title = viewController.title!
        self.window?.setFrame(newWindowFrame, display: true, animate: true)
        self.window?.contentViewController = viewController

        self.lastViewItemIdentifier = toolbarItem.itemIdentifier.rawValue
    }

}
