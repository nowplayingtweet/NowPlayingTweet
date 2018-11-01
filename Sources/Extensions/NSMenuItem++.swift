/**
 *  NSMenuItem++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

extension NSMenuItem {

    func fetchImage(url: URL, rounded: Bool = false) {
        let request = URLRequest(url: url,
                                 cachePolicy: .returnCacheDataElseLoad,
                                 timeoutInterval: 300)
        let conf    = URLSessionConfiguration.default
        let session = URLSession(configuration: conf,
                                 delegate: nil,
                                 delegateQueue: OperationQueue.main)

        session.dataTask(with: request, completionHandler: { data, _, error in
            if let _ = error {
                self.setGuestImage()
                return
            }

            if let imageData = data {
                let image: NSImage? = NSImage(data: imageData)
                self.setImage(rounded ? image?.toRoundCorners() : image)
            }
        }).resume()
    }

    func setGuestImage() {
        self.setImage(NSImage(named: "NSUserGuest", templated: true))
    }

    private func setImage(_ newImage: NSImage?) {
        let size: NSSize      = NSSize(width: 24, height: 24)
        let rect: NSRect      = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        let image: NSImage    = NSImage(size: size, templated: newImage?.isTemplate ?? false)
        image.lockFocus()
        newImage?.draw(in: rect)
        image.unlockFocus()
        self.image = image
    }

}
