/**
 *  GeneralViewController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class GeneralViewController: NSViewController {

    @IBOutlet weak var tweetFormat: NSTextField!
    @IBOutlet weak var tweetWithImage: NSButton!
    @IBOutlet weak var autoTweet: NSButton!

    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    var userDefaults: UserDefaults?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.userDefaults = appDelegate.userDefaults

        // Do any additional setup after loading the view.
        self.tweetWithImage.set(state: (self.userDefaults?.bool(forKey: "TweetWithImage"))!)
        self.autoTweet.set(state: (self.userDefaults?.bool(forKey: "AutoTweet"))!)
        self.updateTweetFormatLabel()
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let subViewController = segue.destinationController as! FormatCustomizeViewController
        subViewController.representedObject = self
    }

    func change(format: String) {
        self.userDefaults?.set(format, forKey: "TweetFormat")
        self.userDefaults?.synchronize()
        self.updateTweetFormatLabel()
    }

    @IBAction func resetFormat(_ sender: NSButton) {
        self.userDefaults?.removeObject(forKey: "TweetFormat")
        self.userDefaults?.synchronize()
        self.updateTweetFormatLabel()
    }

    @IBAction func switchWithImage(_ sender: NSButton) {
        self.userDefaults?.set(sender.stateToBool(), forKey: "TweetWithImage")
    }

    @IBAction func switchAutoTweet(_ sender: NSButton) {
        let notificationObserver: NotificationObserver = NotificationObserver()
        if sender.stateToBool() {
            notificationObserver.addObserver(true, (NSApplication.shared.delegate as! AppDelegate), name: .iTunesPlayerInfo, selector: #selector(AppDelegate.handleNowPlaying(_:)))
        } else {
            notificationObserver.removeObserver(true, (NSApplication.shared.delegate as! AppDelegate), name: .iTunesPlayerInfo)
        }
        self.userDefaults?.set(sender.stateToBool(), forKey: "AutoTweet")
    }

    private func updateTweetFormatLabel() {
        self.tweetFormat.stringValue = (self.userDefaults?.string(forKey: "TweetFormat"))!
    }

}
