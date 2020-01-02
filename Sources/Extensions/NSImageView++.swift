/**
 *  NSImageView++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

extension NSImageView {

    static let session: URLSession = {
        let conf = URLSessionConfiguration.default
        return URLSession(configuration: conf,
                          delegate: nil,
                          delegateQueue: .main)
    }()

    func fetchImage(url: URL, rounded: Bool = false) {
        let request = URLRequest(url: url,
                                 cachePolicy: .returnCacheDataElseLoad,
                                 timeoutInterval: 300)

        NSImageView.session.dataTask(with: request, completionHandler: { data, _, error in
            if let error = error {
                NSLog(error.localizedDescription)
                self.setGuestImage()
                return
            }

            guard let data = data
                , let image = NSImage(data: data) else {
                    self.setGuestImage()
                    return
            }

            self.setImage(image, rounded: rounded)
        }).resume()
    }

    func setGuestImage() {
        self.setImage(NSImage(named: "NSUserGuest", templated: true))
    }

    private func setImage(_ image: NSImage?, rounded: Bool = false) {
        guard let image = image?.resize(targetSize: self.frame.size) else {
            self.image = nil
            return
        }

        self.image = rounded ? image.toRoundCorners() : image
    }

}
