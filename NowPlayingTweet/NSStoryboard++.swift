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
    static let generalViewController = NSStoryboard.SceneIdentifier("GeneralViewController")
    static let accountViewController = NSStoryboard.SceneIdentifier("AccountViewController")
    static let advancedViewController = NSStoryboard.SceneIdentifier("AdvancedViewController")

}
