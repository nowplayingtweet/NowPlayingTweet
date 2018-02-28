/**
 *  GlobalKeyEquivalents.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import AppKit

class GlobalKeyEquivalents {

    static let shared: GlobalKeyEquivalents = GlobalKeyEquivalents()

    let userDefaults: UserDefaults = UserDefaults.standard

    var trusted: Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() : kCFBooleanTrue]
        let trusted = AXIsProcessTrustedWithOptions(options)

        return trusted
    }

    var isEnabled: Bool {
        return self.userDefaults.bool(forKey: "UseKeyShortcut")
    }

    var eventMonitor: Any?

    private weak var delegate: KeyEquivalentsDelegate?

    private init() {
        if !self.trusted {
            self.removeMonitor()
            let alert = NSAlert(message: "Disable Key Equivalents.",
                                informative: """
Not Trusted This Application
Please add/enable with
System Preferences.app -> Security & Privacy -> Privacy -> Accessibility.
""",
                                style: .warning)
            alert.runModal()
            return
        }

        if self.isEnabled  {
            self.eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: self.handleKeyDownEvent(_:))
        }
    }

    func set(delegate: KeyEquivalentsDelegate) {
        self.delegate = delegate
    }

    func addMonitor() throws {
        if !self.trusted {
            self.removeMonitor()
            throw NPTError.NotTrustedApp
        }

        self.userDefaults.set(true, forKey: "UseKeyShortcut")
        self.userDefaults.synchronize()

        self.eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: self.handleKeyDownEvent(_:))
    }

    func removeMonitor() {
        self.userDefaults.set(false, forKey: "UseKeyShortcut")
        self.userDefaults.synchronize()

        NSEvent.removeMonitor(self.eventMonitor)
        self.eventMonitor = nil
    }

    @objc private func handleKeyDownEvent(_ event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let keyCode = event.keyCode
        if flags == .none {
            return
        }

        if flags == [.control, .option] && keyCode == 34 {
            self.delegate?.tweetWithCurrent()
        }
    }

}
