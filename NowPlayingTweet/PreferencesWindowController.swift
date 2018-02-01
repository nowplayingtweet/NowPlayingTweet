/**
 *  PreferencesWindowController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class PreferencesWindowController: NSWindowController {

    @IBOutlet weak var generalToolbarItem: NSToolbarItem!
    @IBOutlet weak var accountsToolbarItem: NSToolbarItem!
    @IBOutlet weak var advancedToolbarItem: NSToolbarItem!
    
    enum PrefViewController: Int {
        case generalViewController
        case accountsViewController
        case advancedViewController
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    @IBAction func switchViewController(_ sender: NSToolbarItem) {
        let selectItem: PrefViewController = PrefViewController(rawValue: sender.tag)!
        print(selectItem)
        
        switch selectItem {
        case .generalViewController:
            replaceViewController("GeneralViewController")
        case .accountsViewController:
            replaceViewController("AccountsViewController")
        case .advancedViewController:
            replaceViewController("AdvancedViewController")
        }
    }

    func replaceViewController(_ identifier: String) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)

        if let viewController = (storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: identifier)) as? NSViewController) {
            let windowFrame = self.window?.frame
            var newWindowFrame: NSRect = (self.window?.frameRect(forContentRect: viewController.view.frame))!
            newWindowFrame.origin.x = (windowFrame?.origin.x)!
            newWindowFrame.origin.y = (windowFrame?.origin.y)! + (windowFrame?.size.height)! - (newWindowFrame.size.height)

            self.window?.contentViewController = nil
            self.window?.setFrame(newWindowFrame, display: true, animate: true)
            self.window?.contentViewController = viewController
        } else {
            return
        }
    }
}
