/**
 *  GeneralViewController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class GeneralViewController: NSViewController {

    @IBOutlet weak var tweetFormat: NSTextField!

    let userDefaults: UserDefaults = UserDefaults.standard
    
    let defaultFormat: String = "#NowPlaying {{Title}} by {{Artist}} from {{Album}}"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.userDefaults.register(defaults: ["TweetFormat": self.defaultFormat])
        self.tweetFormat.stringValue = self.userDefaults.string(forKey: "TweetFormat")!
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let subViewController = segue.destinationController as! FormatCustomizeViewController
        subViewController.representedObject = self
    }

    @IBAction func resetFormat(_ sender: NSButton) {
        self.userDefaults.removeObject(forKey: "TweetFormat")
        self.tweetFormat.stringValue = self.userDefaults.string(forKey: "TweetFormat")!
        self.userDefaults.synchronize()
    }

    func change(format: String) {
        self.tweetFormat.stringValue = format
        self.userDefaults.set(format, forKey: "TweetFormat")
        self.userDefaults.synchronize()
    }

}
