/**
 *  PreferencesWindowController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class PreferencesWindowController: NSWindowController {

    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var generalToolbarItem: NSToolbarItem!
    @IBOutlet weak var accountsToolbarItem: NSToolbarItem!
    @IBOutlet weak var advancedToolbarItem: NSToolbarItem!

    override func windowDidLoad() {
        super.windowDidLoad()

        self.toolbar.selectedItemIdentifier = self.generalToolbarItem.itemIdentifier
    }

    @IBAction func switchViewController(_ sender: NSToolbarItem) {
        switch sender.itemIdentifier {
        case .general:
            self.replaceViewController(identifier: .generalViewController)
        case .accounts:
            self.replaceViewController(identifier: .accountsViewController)
        case .advanced:
            self.replaceViewController(identifier: .advancedViewController)
        default:
            break
        }
    }

    private func replaceViewController(identifier: NSStoryboard.SceneIdentifier) {
        guard let viewController = self.storyboard?.instantiateController(withIdentifier: identifier) as? NSViewController else {
            return
        }

        let windowFrame: NSRect = (self.window?.frame)!
        var newWindowFrame: NSRect = (self.window?.frameRect(forContentRect: viewController.view.frame))!
        newWindowFrame.origin.x = windowFrame.origin.x
        newWindowFrame.origin.y = windowFrame.origin.y + windowFrame.size.height - newWindowFrame.size.height

        self.window?.contentViewController = nil
        self.window?.setFrame(newWindowFrame, display: true, animate: true)
        self.window?.contentViewController = viewController
    }

}
