/**
 *  NSImage++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

extension NSImage {

    func toRoundCorners(width: CGFloat = 48, height: CGFloat = 48) -> NSImage? {
        let xRad = width / 2
        let yRad = height / 2
        let image: NSImage = self
        let imageSize: NSSize = image.size
        let newSize = NSMakeSize(imageSize.width, imageSize.height)
        let composedImage = NSImage(size: newSize)

        composedImage.lockFocus()
        let ctx = NSGraphicsContext.current
        ctx?.imageInterpolation = NSImageInterpolation.high

        let imageFrame = NSRect(x: 0, y: 0, width: width, height: height)
        let clipPath = NSBezierPath(roundedRect: imageFrame, xRadius: xRad, yRadius: yRad)
        clipPath.windingRule = .evenOddWindingRule
        clipPath.addClip()

        let rect = NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        image.draw(at: .zero, from: rect, operation: .sourceOver, fraction: 1)
        composedImage.unlockFocus()

        return composedImage
    }

    func toData(from fileType: NSBitmapImageRep.FileType, quality: CGFloat = 1) -> Data? {
        let dict: Dictionary<NSBitmapImageRep.PropertyKey, Any> = [NSBitmapImageRep.PropertyKey.compressionFactor: NSNumber(value: Float(quality))]
        let imageRep: NSBitmapImageRep = NSBitmapImageRep(data: self.tiffRepresentation!)!
        return imageRep.representation(using: fileType, properties: dict)
    }

}
