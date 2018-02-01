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
        self.tweetWithImage.state = change(toState: "TweetWithImage")
        self.autoTweet.state = change(toState: "AutoTweet")
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
        var bool = true
        switch sender.state {
        case .on:
            bool = true
        case .off:
            bool = false
        default:
            break
        }
        self.userDefaults.set(bool, forKey: (sender.identifier?.rawValue)!)
    }

    private func change(toState: String) -> NSControl.StateValue {
        return self.userDefaults.bool(forKey: toState) ? .on : .off
    }

    private func updateTweetFormatLabel() {
        self.tweetFormat.stringValue = self.userDefaults.string(forKey: "TweetFormat")!
    }
}
