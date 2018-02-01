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
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }

    @IBAction func switchViewController(_ sender: NSToolbarItem) {
        let selectItem: Int = sender.tag
    }

}
