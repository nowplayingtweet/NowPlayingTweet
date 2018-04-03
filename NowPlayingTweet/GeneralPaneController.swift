/**
 *  GeneralPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class GeneralPaneController: NSViewController {

    @IBOutlet weak var tweetFormatView: NSScrollView!
    @IBOutlet var tweetFormat: NSTextView!
    @IBOutlet weak var editButton: NSButton!

    private let userDefaults: UserDefaults = UserDefaults.standard

    static let shared: GeneralPaneController = {
        let storyboard = NSStoryboard(name: .main, bundle: .main)
        let windowController = storyboard.instantiateController(withIdentifier: .generalPaneController)
        return windowController as! GeneralPaneController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.updateTweetFormatLabel()
    }

    override func cancelOperation(_ sender: Any?) {
        self.updateTweetFormatLabel()
    }

    @IBAction private func editFormat(_ sender: NSButton) {
        if self.tweetFormat.isEditable {
            self.change()
        } else {
            self.editButton.title = "Change"
            self.editButton.keyEquivalent = "\r"
            self.tweetFormatView.borderType = .bezelBorder
            self.tweetFormat.textColor = .textColor
            self.tweetFormat.drawsBackground = true
            self.tweetFormat.isEditable = true
        }
    }

    @IBAction private func resetFormat(_ sender: NSButton) {
        self.userDefaults.removeObject(forKey: "TweetFormat")
        self.userDefaults.synchronize()
        self.updateTweetFormatLabel()
    }

    private func change() {
        self.userDefaults.set(self.tweetFormat.string, forKey: "TweetFormat")
        self.userDefaults.synchronize()
        self.updateTweetFormatLabel()
    }

    private func updateTweetFormatLabel() {
        self.editButton.title = "Edit"
        self.editButton.keyEquivalent = ""
        self.tweetFormatView.borderType = .noBorder
        self.tweetFormat.textColor = .labelColor
        self.tweetFormat.drawsBackground = false
        self.tweetFormat.isSelectable = false
        self.tweetFormat.string = (self.userDefaults.string(forKey: "TweetFormat"))!
    }

}
