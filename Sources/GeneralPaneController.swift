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

    @IBOutlet weak var postFormat: NSTextField!

    @IBOutlet weak var gridView: NSGridView!

    private var userDefaultsPostFormat: String? {
        get {
            return UserDefaults.standard.string(forKey: "PostFormat")
        }
        set(newValue) {
            if let stringValue = newValue, !stringValue.isEmpty {
                UserDefaults.standard.set(stringValue, forKey: "PostFormat")
            } else {
                UserDefaults.standard.removeObject(forKey: "PostFormat")
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

        self.postFormat.stringValue = self.userDefaultsPostFormat!
    }

    @IBAction private func resetFormat(_ sender: NSButton) {
        self.userDefaultsPostFormat = nil
        self.postFormat.stringValue = self.userDefaultsPostFormat!
    }

    func controlTextDidChange(_ notification: Notification) {
        if let textField = notification.object as? NSTextField {
            self.userDefaultsPostFormat = textField.stringValue
        }
    }

}
