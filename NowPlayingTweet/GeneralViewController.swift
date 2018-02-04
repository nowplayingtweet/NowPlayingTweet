/**
 *  GeneralViewController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class GeneralViewController: NSViewController {

    @IBOutlet weak var tweetFormatView: NSScrollView!
    @IBOutlet var tweetFormat: NSTextView!
    @IBOutlet weak var editButton: NSButton!
    
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    var userDefaults: UserDefaults?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.userDefaults = appDelegate.userDefaults

        self.updateTweetFormatLabel()
    }

    @IBAction func editFormat(_ sender: NSButton) {
        let isEditable = self.tweetFormat.isEditable

        if isEditable {
            self.change(format: self.tweetFormat.string)
            self.updateTweetFormatLabel()
        }

        self.editButton.keyEquivalent = isEditable ? "" : "\r"
        self.tweetFormatView.borderType = isEditable ? .noBorder : .bezelBorder
        self.tweetFormat.textColor = isEditable ? .labelColor : .textColor
        self.tweetFormat.drawsBackground = isEditable ? false : true
        self.tweetFormat.isEditable = isEditable ? false : true
    }

    @IBAction func resetFormat(_ sender: NSButton) {
        self.userDefaults?.removeObject(forKey: "TweetFormat")
        self.userDefaults?.synchronize()
        self.updateTweetFormatLabel()
    }

    func change(format: String) {
        self.userDefaults?.set(format, forKey: "TweetFormat")
        self.userDefaults?.synchronize()
    }

    private func updateTweetFormatLabel() {
        self.tweetFormat.string = (self.userDefaults?.string(forKey: "TweetFormat"))!
    }

}
