//
//  AuthorizeSheetController.swift
//  NowPlayingTweet
//
//  Created by kPherox on 2019/12/22.
//  Copyright © 2019 kPherox. All rights reserved.
//

import Cocoa

class AuthorizeSheetController: NSViewController {

    enum AuthorizeMode: String {
        case AuthorizationCode = "authorization_code"
        case Callback = "callback"
    }

    static let shared: AuthorizeSheetController = {
        let windowController = NSStoryboard.main!.instantiateController(withIdentifier: .authorizeSheetController)
        return windowController as! AuthorizeSheetController
    }()

    @IBOutlet weak var serverURL: NSTextField!

    private var authorizeMode: AuthorizeMode = .Callback

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.authorizeMode = .Callback
        self.serverURL.stringValue = ""
    }

    @IBAction func switchAuthorizeMode(_ sender: NSButton) {
        if let authorizeMode = AuthorizeMode(rawValue: String(describing: sender.identifier)) {
            self.authorizeMode = authorizeMode
        }
    }

    @IBAction func sendServerURL(_ sender: Any) {
        let userInfo = [
            "server_url" : self.serverURL.stringValue,
            "authorize_mode" : String(describing: self.authorizeMode)
        ]

        NotificationQueue.default.enqueue(.init(name: .authorize,
                                                object: nil,
                                                userInfo: userInfo),
                                          postingStyle: .asap)
    }

}
