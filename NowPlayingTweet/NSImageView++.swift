/**
 *  NSImageView++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import AppKit

extension NSImageView {

    func fetchImage(url: URL) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 300)
        let conf =  URLSessionConfiguration.default
        let session = URLSession(configuration: conf, delegate: nil, delegateQueue: OperationQueue.main)

        session.dataTask(with: request, completionHandler: { data, _, error in
            if let error = error {
                NSLog(error.localizedDescription)
            }
            if let imageData = data {
                self.image = NSImage(data: imageData)
            }
        }).resume()
    }

}
