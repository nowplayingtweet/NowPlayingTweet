/**
 *  NSImage++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

extension NSImage {

    convenience init?(named name: NSImage.Name, templated: Bool) {
        self.init(named: name)
        self.isTemplate = templated
    }

    convenience init?(data: Data, templated: Bool) {
        self.init(data: data)
        self.isTemplate = templated
    }

    convenience init(size: NSSize, templated: Bool) {
        self.init(size: size)
        self.isTemplate = templated
    }

}

extension NSImage {

    func resize(targetSize: CGSize) -> NSImage {
        let image: NSImage = self
        let composedImage = NSImage(size: targetSize, templated: self.isTemplate)

        composedImage.lockFocus()
        let ctx = NSGraphicsContext.current
        ctx?.imageInterpolation = NSImageInterpolation.high

        let rect = NSRect(origin: .zero, size: targetSize)
        image.draw(in: rect)
        composedImage.unlockFocus()

        return composedImage
    }

    func toRoundCorners() -> NSImage {
        let image: NSImage = self
        let imageSize: NSSize = image.size
        let imageFrame = NSRect(origin: .zero, size: imageSize)
        let xRadius = imageSize.width / 2
        let yRadius = imageSize.height / 2
        let composedImage = NSImage(size: imageSize, templated: self.isTemplate)

        composedImage.lockFocus()
        let ctx = NSGraphicsContext.current
        ctx?.imageInterpolation = NSImageInterpolation.high

        let clipPath = NSBezierPath(roundedRect: imageFrame, xRadius: xRadius, yRadius: yRadius)
        clipPath.windingRule = .evenOdd
        clipPath.addClip()

        image.draw(at: .zero, from: imageFrame, operation: .sourceOver, fraction: 1)
        composedImage.unlockFocus()

        return composedImage
    }

}
