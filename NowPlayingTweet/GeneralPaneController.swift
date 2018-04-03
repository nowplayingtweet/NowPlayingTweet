/**
 *  GeneralPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import TwitterText

class GeneralPaneController: NSViewController {

    static let shared: GeneralPaneController = {
        let storyboard = NSStoryboard(name: .main, bundle: .main)
        let windowController = storyboard.instantiateController(withIdentifier: .generalPaneController)
        return windowController as! GeneralPaneController
    }()

    @IBOutlet weak var tweetFormatView: NSScrollView!
    @IBOutlet var tweetFormat: NSTextView!
    @IBOutlet weak var editButton: NSButton!
    @IBOutlet weak var textCounter: NSTextField!

    private let userDefaults: UserDefaults = UserDefaults.standard

    private var keyUpMonitor: Any?

    private let twitterTextParser: TwitterTextParser = {
        var twitterTextConfig = TwitterTextConfiguration(fromJSONResource: kTwitterTextParserConfigurationV2)
        return TwitterTextParser(configuration: twitterTextConfig)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tweetFormat.string = (self.userDefaults.string(forKey: "TweetFormat"))!
        self.updateCounter()
    }

    override func cancelOperation(_ sender: Any?) {
        self.tweetFormat.string = (self.userDefaults.string(forKey: "TweetFormat"))!
        self.completeEditing()
    }

    override func keyUp(with event: NSEvent) {
        self.updateCounter()
    }

    @IBAction private func editFormat(_ sender: NSButton) {
        if self.tweetFormat.isEditable {
            self.change()
        } else {
            self.keyUpMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyUp, handler: { event -> NSEvent? in
                self.keyUp(with: event)
                return event
            })

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
        self.tweetFormat.string = (self.userDefaults.string(forKey: "TweetFormat"))!
        self.completeEditing()
    }

    private func change() {
        self.userDefaults.set(self.tweetFormat.string, forKey: "TweetFormat")
        self.userDefaults.synchronize()
        self.tweetFormat.string = (self.userDefaults.string(forKey: "TweetFormat"))!
        self.completeEditing()
    }

    private func updateCounter() {
        let results: TwitterTextParseResults = self.twitterTextParser.parseTweet(self.tweetFormat.string)
        
        self.textCounter.stringValue = String(results.weightedLength) + "/" + String(self.twitterTextParser.maxWeightedTweetLength())
    }

    private func completeEditing() {
        self.updateCounter()
        NSEvent.removeMonitor(self.keyUpMonitor)
        self.editButton.title = "Edit"
        self.editButton.keyEquivalent = ""
        self.tweetFormatView.borderType = .noBorder
        self.tweetFormat.textColor = .labelColor
        self.tweetFormat.drawsBackground = false
        self.tweetFormat.isSelectable = false
    }

}
