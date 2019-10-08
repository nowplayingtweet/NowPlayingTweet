/**
 *  GeneralPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class GeneralPaneController: NSViewController, NSTextFieldDelegate {

    static let shared: GeneralPaneController = {
        let windowController = NSStoryboard.main!.instantiateController(withIdentifier: .generalPaneController)
        return windowController as! GeneralPaneController
    }()

    static let formatVariables: KeyValuePairs = [
        "{{Title}}": "Track Title",
        "{{Artist}}": "Artist Name",
        "{{Album}}": "Album Title",
        "{{AlbumArtist}}": "Album Artist Name",
    ]

    @IBOutlet weak var tweetFormat: NSTextField!

    private let userDefaults: UserDefaults = UserDefaults.standard

    @IBOutlet weak var gridView: NSGridView!

    override func viewDidLoad() {
        super.viewDidLoad()

        for (name, desc) in Self.formatVariables {
            let nameLabel = NSTextField(labelWithString: name + ":")
            nameLabel.alignment = .right
            let descLabel = NSTextField(labelWithString: desc)
            let variableRow = self.gridView.addRow(with: [nameLabel, descLabel])
            variableRow.height = 17
            variableRow.yPlacement = .top
        }

        self.tweetFormat.stringValue = (self.userDefaults.string(forKey: "TweetFormat"))!
    }

    @IBAction private func resetFormat(_ sender: NSButton) {
        self.userDefaults.removeObject(forKey: "TweetFormat")
        self.userDefaults.synchronize()
        self.tweetFormat.stringValue = (self.userDefaults.string(forKey: "TweetFormat"))!
    }

    func controlTextDidChange(_ notification: Notification) {
        guard let textField = notification.object as? NSTextField else {
            return
        }

        self.userDefaults.set(textField.stringValue, forKey: "TweetFormat")
    }

    func controlTextDidEndEditing(_ notification: Notification) {
        if let _ = notification.object as? NSTextField {
            self.userDefaults.synchronize()
        }
    }

}
