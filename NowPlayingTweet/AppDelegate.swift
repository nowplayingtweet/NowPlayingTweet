//
//  AppDelegate.swift
//  NowPlayingTweet
//
//  Created by kPherox on 2018/02/01.
//  Copyright © 2018 kPherox. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        self.statusItem.title = "NPT"
        self.statusItem.highlightMode = true
        self.statusItem.menu = self.menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

