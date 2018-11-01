/**
 *  NSStoryboard++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

extension NSStoryboard.Name {

    static let main: NSStoryboard.Name = NSStoryboard.Name(Bundle.main.infoDictionary!["NSMainStoryboardFile"] as! String)

}

extension NSStoryboard.SceneIdentifier {

    static let preferencesWindowController = NSStoryboard.SceneIdentifier("PreferencesWindowController")
    static let generalPaneController = NSStoryboard.SceneIdentifier("GeneralPaneController")
    static let accountPaneController = NSStoryboard.SceneIdentifier("AccountPaneController")
    static let advancedPaneController = NSStoryboard.SceneIdentifier("AdvancedPaneController")
    static let keyEquivalentsPaneController = NSStoryboard.SceneIdentifier("KeyEquivalentsPaneController")

}
