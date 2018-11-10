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

    private let userDefaults: UserDefaults = UserDefaults.standard

    private let accounts: SocialAccounts = SocialAccounts.shared

    private let keyEquivalents: GlobalKeyEquivalents = GlobalKeyEquivalents.shared

    @IBOutlet weak var currentRecordLabel: NSTextField!
    @IBOutlet weak var currentRecordView: RecordView!

    @IBOutlet weak var accountShortcutLabel: NSTextField!

    private var selectedRecortView: RecordView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        self.currentRecordView.tintColor = .systemBlue
        self.currentRecordView.cornerRadius = 12
        self.currentRecordView.delegate = self
        self.currentRecordView.identifier = NSUserInterfaceItemIdentifier(rawValue: "Current")
        self.currentRecordView.keyCombo = self.userDefaults.keyCombo(forKey: "Current")

        self.reloadView()

        let reloadView: (Notification) -> () = { notification in
            self.reloadView()
        }
        NotificationCenter.default.addObserver(forName: .login, object: nil, queue: nil, using: reloadView)
        NotificationCenter.default.addObserver(forName: .logout, object: nil, queue: nil, using: reloadView)
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.reloadView()
    }

    override func cancelOperation(_ sender: Any?) {
        self.selectedRecortView?.endRecording()
    }

    private func reloadView() {
        for subview in self.view.subviews {
            switch subview {
            case self.currentRecordLabel, self.currentRecordView, self.accountShortcutLabel:
                continue
            default:
                subview.removeFromSuperview()
            }
        }

        let existAccount = self.accounts.existsAccount

        self.accountShortcutLabel.isHidden = !existAccount

        let accountRowsHeight = 32 * self.accounts.count
        let frameHeight: CGFloat = CGFloat(existAccount ? 64 + 44 + accountRowsHeight : 64)
        let frameSize: CGSize = CGSize(width: 500, height: frameHeight)

        self.view.setFrameSize(frameSize)
        self.view.window?.setContentSize(frameSize)

        if !existAccount {
            return
        }

        let labelSize = self.currentRecordLabel.frame.size
        let viewSize = self.currentRecordView.frame.size

        let labelXPoint = self.currentRecordLabel.frame.origin.x
        let viewXPoint = self.currentRecordView.frame.origin.x

        var labelYPoint = 28 + accountRowsHeight
        var viewYPoint = 25 + accountRowsHeight

        for account in self.accounts.all() {
            labelYPoint -= 32
            viewYPoint -= 32
            let labelPoint = CGPoint(x: labelXPoint, y: CGFloat(labelYPoint))
            let viewPoint = CGPoint(x: viewXPoint, y: CGFloat(viewYPoint))

            let labelFrame = CGRect(origin: labelPoint, size: labelSize)
            let viewFrame = CGRect(origin: viewPoint, size: viewSize)

            let accountName: String = account.screenName ?? "null"
            let recordLabel: NSTextField = Label(with: "Tweet with @\(accountName):",
                                                 frame: labelFrame,
                                                 alignment: .right) as NSTextField

            let recordView: RecordView = RecordView(frame: viewFrame)
            recordView.tintColor = .systemBlue
            recordView.cornerRadius = 12
            recordView.delegate = self
            recordView.identifier = NSUserInterfaceItemIdentifier(rawValue: account.userID)
            recordView.keyCombo = self.userDefaults.keyCombo(forKey: account.userID)

            self.view.addSubview(recordLabel)
            self.view.addSubview(recordView)
        }
    }

    func recordViewShouldBeginRecording(_ recordView: RecordView) -> Bool {
        if recordView.identifier == nil { return false }
        recordView.keyCombo = nil
        self.selectedRecortView = recordView
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
        self.selectedRecortView = nil
        guard let identifier: String = recordView.identifier?.rawValue else { return }
        recordView.keyCombo = self.userDefaults.keyCombo(forKey: identifier)
    }

}
