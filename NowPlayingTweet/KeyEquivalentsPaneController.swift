/**
 *  KeyEquivalentsPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import Magnet
import KeyHolder

class KeyEquivalentsPaneController: NSViewController, RecordViewDelegate {

    static let shared: KeyEquivalentsPaneController = {
        let storyboard = NSStoryboard(name: .main, bundle: .main)
        let windowController = storyboard.instantiateController(withIdentifier: .keyEquivalentsPaneController)
        return windowController as! KeyEquivalentsPaneController
    }()

    var userDefaults: UserDefaults = UserDefaults.standard

    let twitterClient: TwitterClient = TwitterClient.shared

    let keyEquivalents: GlobalKeyEquivalents = GlobalKeyEquivalents.shared

    @IBOutlet var currentRecortView: RecordView!

    @IBOutlet weak var accountShortcutLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        self.currentRecortView.tintColor = .systemBlue
        self.currentRecortView.cornerRadius = 12
        self.currentRecortView.delegate = self
        self.currentRecortView.identifier = NSUserInterfaceItemIdentifier(rawValue: "Current")
        self.currentRecortView.keyCombo = self.userDefaults.keyCombo(forKey: "Current")
    }

    func recordViewShouldBeginRecording(_ recordView: RecordView) -> Bool {
        guard let _: String = recordView.identifier?.rawValue else { return false }
        recordView.keyCombo = nil
        return true
    }

    func recordView(_ recordView: RecordView, canRecordKeyCombo keyCombo: KeyCombo) -> Bool {
        guard let identifier: String = recordView.identifier?.rawValue else { return false }
        self.keyEquivalents.unregister(identifier)
        return true
    }

    func recordViewDidClearShortcut(_ recordView: RecordView) {
        guard let identifier: String = recordView.identifier?.rawValue else { return }
        self.keyEquivalents.unregister(identifier)
    }

    func recordView(_ recordView: RecordView, didChangeKeyCombo keyCombo: KeyCombo) {
        guard let identifier: String = recordView.identifier?.rawValue else { return }
        self.keyEquivalents.register(identifier, keyCombo: keyCombo)
    }

    func recordViewDidEndRecording(_ recordView: RecordView) {
        guard let identifier: String = recordView.identifier?.rawValue else { return }
        recordView.keyCombo = self.userDefaults.keyCombo(forKey: identifier)
    }

    @IBAction func changeCancel(_ sender: NSButton) {
        self.currentRecortView.endRecording()
    }

}
