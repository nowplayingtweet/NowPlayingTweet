/**
 *  FormatCustomizeViewController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class FormatCustomizeViewController: NSViewController {

    @IBOutlet weak var tweetFormat: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override func viewWillAppear() {
        self.tweetFormat.stringValue = (self.representedObject as! GeneralViewController).userDefaults.string(forKey: "TweetFormat")!
    }

    override func viewWillDisappear() {
        (self.representedObject as! GeneralViewController).change(format: self.tweetFormat.stringValue)
    }

}
