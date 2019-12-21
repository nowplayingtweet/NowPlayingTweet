/**
 *  NotificationObserver.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation

class NotificationObserver {

    private let notificationCenter: NotificationCenter = NotificationCenter.default

    private let distNotificationCenter: DistributedNotificationCenter = DistributedNotificationCenter.default()

    func addObserver(_ observer: Any, name: Notification.Name, selector: Selector, object: Any?, distributed: Bool = false) {
        if distributed {
            self.distNotificationCenter.addObserver(observer, selector: selector, name: name, object: object as? String)
        } else {
            self.notificationCenter.addObserver(observer, selector: selector, name: name, object: object)
        }
    }

    func removeObserver(_ observer: Any, name: Notification.Name, object: Any?, distributed: Bool = false) {
        if distributed {
            self.distNotificationCenter.removeObserver(observer, name: name, object: object as? String)
        } else {
            self.notificationCenter.removeObserver(observer, name: name, object: object)
        }
    }

}
