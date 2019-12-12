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

    @IBOutlet weak var gridView: NSGridView!

    private var userDefaultsTweetFormat: String? {
        get {
            return UserDefaults.standard.string(forKey: "TweetFormat")
        }
        set(newValue) {
            if let stringValue = newValue, !stringValue.isEmpty {
                UserDefaults.standard.set(stringValue, forKey: "TweetFormat")
            } else {
                UserDefaults.standard.removeObject(forKey: "TweetFormat")
            }
            UserDefaults.standard.synchronize()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for (name, description) in Self.formatVariables {
            let nameLabel = NSTextField(labelWithString: name + ":")

            let descriptionLabel = NSTextField(labelWithString: description)

            let variableRow = self.gridView.addRow(with: [nameLabel, descriptionLabel])
            variableRow.height = 17
        }

        self.tweetFormat.stringValue = self.userDefaultsTweetFormat!
    }

    @IBAction private func resetFormat(_ sender: NSButton) {
        self.userDefaultsTweetFormat = nil
        self.tweetFormat.stringValue = self.userDefaultsTweetFormat!
    }

    func controlTextDidChange(_ notification: Notification) {
        if let textField = notification.object as? NSTextField {
            self.userDefaultsTweetFormat = textField.stringValue
        }
    }

}
