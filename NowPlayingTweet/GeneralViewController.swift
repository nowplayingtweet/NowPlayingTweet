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
    
    let userDefaults: UserDefaults = UserDefaults.standard
    
    let defaultSettings: [String : Any] = [
        "TweetFormat": "#NowPlaying {{Title}} by {{Artist}} from {{Album}}",
        "TweetWithImage": true,
        "AutoTweet": true,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.userDefaults.register(defaults: self.defaultSettings)
        self.tweetWithImage.set(state: self.userDefaults.bool(forKey: "TweetWithImage"))
        self.autoTweet.set(state: self.userDefaults.bool(forKey: "AutoTweet"))
        self.updateTweetFormatLabel()
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let subViewController = segue.destinationController as! FormatCustomizeViewController
        subViewController.representedObject = self
    }
    
    func change(format: String) {
        self.userDefaults.set(format, forKey: "TweetFormat")
        self.userDefaults.synchronize()
        self.updateTweetFormatLabel()
    }

    @IBAction func resetFormat(_ sender: NSButton) {
        self.userDefaults.removeObject(forKey: "TweetFormat")
        self.userDefaults.synchronize()
        self.updateTweetFormatLabel()
    }

    @IBAction func switchState(_ sender: NSButton) {
        self.userDefaults.set(sender.stateToBool(), forKey: (sender.identifier?.rawValue)!)
    }

    private func updateTweetFormatLabel() {
        self.tweetFormat.stringValue = self.userDefaults.string(forKey: "TweetFormat")!
    }
}
