/**
 *  AdvancedViewController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class AdvancedViewController: NSViewController {

    @IBOutlet weak var tweetWithImage: NSButton!
    @IBOutlet weak var autoTweet: NSButton!

    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    var userDefaults: UserDefaults?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        self.userDefaults = appDelegate.userDefaults

        self.tweetWithImage.set(state: (self.userDefaults?.bool(forKey: "TweetWithImage"))!)
        self.autoTweet.set(state: (self.userDefaults?.bool(forKey: "AutoTweet"))!)
    }

    @IBAction func switchWithImage(_ sender: NSButton) {
        self.userDefaults?.set(sender.state.toBool(), forKey: "TweetWithImage")
    }

    @IBAction func switchAutoTweet(_ sender: NSButton) {
        let notificationObserver: NotificationObserver = NotificationObserver()
        if sender.state.toBool() {
            notificationObserver.addObserver(true, (NSApplication.shared.delegate as! AppDelegate), name: .iTunesPlayerInfo, selector: #selector(AppDelegate.handleNowPlaying(_:)))
        } else {
            notificationObserver.removeObserver(true, (NSApplication.shared.delegate as! AppDelegate), name: .iTunesPlayerInfo)
        }
        self.userDefaults?.set(sender.state.toBool(), forKey: "AutoTweet")
    }

}
