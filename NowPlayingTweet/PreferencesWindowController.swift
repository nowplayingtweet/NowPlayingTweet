/**
 *  PreferencesWindowController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class PreferencesWindowController: NSWindowController {

    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var generalPane: NSToolbarItem!
    @IBOutlet weak var accountPane: NSToolbarItem!
    @IBOutlet weak var advancedPane: NSToolbarItem!
    @IBOutlet weak var keyEquivalentsPane: NSToolbarItem!

    var userDefaults: UserDefaults = UserDefaults.standard

    static let shared: PreferencesWindowController = {
        let storyboard = NSStoryboard(name: .main, bundle: .main)
        let windowController = storyboard.instantiateController(withIdentifier: .preferencesWindowController)
        return windowController as! PreferencesWindowController
    }()

    private let viewControllers: [NSViewController] = [
        GeneralPaneController.shared,
        AccountPaneController.shared,
        AdvancedPaneController.shared,
        KeyEquivalentsPaneController.shared,
        ]

    override func windowDidLoad() {
        super.windowDidLoad()

        let items: [NSToolbarItem] = [
            self.generalPane,
            self.accountPane,
            self.advancedPane,
            self.keyEquivalentsPane,
            ]

        let lastViewItemIdentifier = NSToolbarItem.Identifier(self.userDefaults.string(forKey: "lastViewItemIdentifier") ?? "")

        guard let item = items.first(where: { $0.itemIdentifier == lastViewItemIdentifier }) ?? self.generalPane else {
            self.window?.center()
            return
        }

        self.toolbar.selectedItemIdentifier = item.itemIdentifier

        self.switchView(item)
        self.window?.center()

        self.window?.level = .floating
    }

    @IBAction func cancel(_ sender: Any?) {
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

        self.userDefaults.set(toolbarItem.itemIdentifier.rawValue, forKey: "lastViewItemIdentifier")
    }

}
