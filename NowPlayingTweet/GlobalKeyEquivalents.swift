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

    var trusted: Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() : kCFBooleanTrue]
        let trusted = AXIsProcessTrustedWithOptions(options)

        return trusted
    }

    var eventMonitor: Any?

    let userDefaults: UserDefaults = UserDefaults.standard

    private init() {
        if self.trusted {//self.userDefaults.bool(forKey: "isUseKeyShortcut") {
            // Handle key doen event
            self.eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: self.handleKeyDownEvent(_:))
        }
    }

    @objc func handleKeyDownEvent(_ event: NSEvent) {
        //
        let flags = event.modifierFlags
        let keyCode = event.keyCode
        if flags == .none {
            return
        }

        print(flags, keyCode)
    }

}
