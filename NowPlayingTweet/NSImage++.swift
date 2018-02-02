/**
 *  NSImage++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import AppKit

extension NSImage {
    func toData(from fileType: NSBitmapImageRep.FileType, quality: CGFloat = 1) -> Data? {
        let dict: Dictionary<NSBitmapImageRep.PropertyKey, Any> = [NSBitmapImageRep.PropertyKey.compressionFactor: NSNumber.init(value: Float(quality))]
        let imageRep: NSBitmapImageRep = NSBitmapImageRep(data: self.tiffRepresentation!)!
        return imageRep.representation(using: fileType, properties: dict)
    }
}
