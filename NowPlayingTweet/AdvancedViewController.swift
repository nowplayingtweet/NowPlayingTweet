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
    }

    @IBAction func switchSetting(_ sender: NSButton) {
        let identifier: String = (sender.identifier?.rawValue)!
        if identifier == "AutoTweet" {
            self.autoTweet(state: sender.state.toBool())
        }
        self.userDefaults.set(sender.state.toBool(), forKey: identifier)
        self.userDefaults.synchronize()
    }

    private func autoTweet(state: Bool) {
        let notificationObserver: NotificationObserver = NotificationObserver()
        if state {
            notificationObserver.addObserver(self.appDelegate,
                                             name: .iTunesPlayerInfo,
                                             selector: #selector(self.appDelegate.handleNowPlaying(_:)),
                                             object: nil,
                                             distributed: true)
        } else {
            notificationObserver.removeObserver(self.appDelegate,
                                                name: .iTunesPlayerInfo,
                                                object: nil,
                                                distributed: true)
        }
    }

}
