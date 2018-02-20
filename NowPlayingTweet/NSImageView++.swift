/**
 *  NSImageView++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import AppKit

extension NSImageView {

    static let session: URLSession = {
        let conf =  URLSessionConfiguration.default
        return URLSession(configuration: conf,
                             delegate: nil,
                             delegateQueue: OperationQueue.main)
    }()

    func fetchImage(url: URL, rounded: Bool = false) {
        let request = URLRequest(url: url,
                                 cachePolicy: .returnCacheDataElseLoad,
                                 timeoutInterval: 300)

        NSImageView.session.dataTask(with: request, completionHandler: { data, _, error in
            if let error = error {
                NSLog(error.localizedDescription)
            }
            if let imageData = data {
                let image: NSImage = NSImage(data: imageData)!
                self.image = rounded ? image.toRoundCorners() : image
            }
        }).resume()
    }

}
