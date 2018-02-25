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

    private init() {
        if !self.trusted {
            return
        }

        if self.isEnabled  {
            self.eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: self.handleKeyDownEvent(_:))
        }
    }

    func addMonitor() throws {
        if !self.trusted {
            self.userDefaults.set(false, forKey: "UseKeyShortcut")
            throw NPTError.NotTrustedApp
        }

        self.userDefaults.set(true, forKey: "UseKeyShortcut")
        self.userDefaults.synchronize()

        self.eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: self.handleKeyDownEvent(_:))
    }

    func removeMonitor() throws {
        self.userDefaults.set(false, forKey: "UseKeyShortcut")
        self.userDefaults.synchronize()

        guard let eventMonitor = self.eventMonitor else {
            throw NPTError.Unknown("Have not eventMonitor")
        }

        NSEvent.removeMonitor(eventMonitor)
        self.eventMonitor = nil
    }

    @objc private func handleKeyDownEvent(_ event: NSEvent) {
        //
        let flags = event.modifierFlags
        let keyCode = event.keyCode
        if flags == .none {
            return
        }

        print(flags, keyCode)
    }

}
