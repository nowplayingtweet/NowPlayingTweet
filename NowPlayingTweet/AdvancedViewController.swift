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

    var userDefaults: UserDefaults = UserDefaults.standard

    static let shared: AdvancedViewController = {
        let storyboard = NSStoryboard(name: .main, bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: .advancedViewController)
        return windowController as! AdvancedViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.
        self.tweetWithImage.set(state: self.userDefaults.bool(forKey: "TweetWithImage"))
        self.autoTweet.set(state: self.userDefaults.bool(forKey: "AutoTweet"))

        if self.userDefaults.bool(forKey: "AutoTweet") {
            let notificationCenter: NotificationCenter = NotificationCenter.default
            var observer: NSObjectProtocol!
            observer = notificationCenter.addObserver(forName: .disableAutoTweet, object: nil, queue: nil, using: { notification in
                self.autoTweet.set(state: self.userDefaults.bool(forKey: "AutoTweet"))
                notificationCenter.removeObserver(observer)
            })
        }
    }

    @IBAction func switchSetting(_ sender: NSButton) {
        let identifier: String = (sender.identifier?.rawValue)!
        if identifier != "AutoTweet" {
            self.userDefaults.set(sender.state.toBool(), forKey: identifier)
            self.userDefaults.synchronize()
            return
        }

        self.appDelegate.switchAutoTweet(state: sender.state.toBool())

        let notificationCenter: NotificationCenter = NotificationCenter.default
        if sender.state.toBool() {
            var observer: NSObjectProtocol!
            observer = notificationCenter.addObserver(forName: .disableAutoTweet, object: nil, queue: nil, using: { notification in
                self.autoTweet.set(state: self.userDefaults.bool(forKey: "AutoTweet"))
                notificationCenter.removeObserver(observer)
            })
        } else {
            notificationCenter.post(name: .disableAutoTweet, object: nil)
        }
    }

}
