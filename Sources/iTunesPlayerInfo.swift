/**
 *  iTunesPlayerInfo.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import iTunesBridge
import ScriptingBridge

class iTunesPlayerInfo {

    struct Track {
        let title: String?

        let artist: String?

        let album: String?

        let albumArtist: String?

        let bitRate: Int?

        let artworks: [iTunesArtwork]

        var artwork: NSImage? {
            return self.artworks[safe: 0]?.data
        }
    }

    private var itunes: iTunesApplication? {
        if #available(OSX 10.14, *) {
            let targetAppEventDescriptor: NSAppleEventDescriptor = NSAppleEventDescriptor(bundleIdentifier: "com.apple.iTunes")
            let status: OSStatus = AEDeterminePermissionToAutomateTarget(targetAppEventDescriptor.aeDesc, typeWildCard, typeWildCard, true)
            switch status {
              case noErr:
                return SBApplication(bundleIdentifier: "com.apple.iTunes")
              case OSStatus(procNotFound):
                print("Not Running iTunes")
              case OSStatus(errAEEventNotPermitted):
                print("Has not permission iTunes.app")
              default:
                break
            }

            return nil
        } else {
            if !self.isRunningiTunes {
                return nil
            }

            return SBApplication(bundleIdentifier: "com.apple.iTunes")
        }
    }

    var currentTrack: iTunesPlayerInfo.Track?

    var isRunningiTunes: Bool {
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.iTunes")

        return !runningApps.isEmpty
    }

    var existTrack: Bool {
        return self.currentTrack != nil
    }

    init() {
        self.updateTrack()
    }

    func updateTrack() {
        if self.itunes == nil {
            self.currentTrack = nil
            return
        }

        guard let currentTrack = self.itunes!.currentTrack else {
            self.currentTrack = nil
            return
        }

        self.currentTrack = self.convert(from: currentTrack)
    }

    private func convert(from itunesTrack: iTunesTrack) -> Track {
        let trackArtworks: [iTunesArtwork] = itunesTrack.artworks!() as! [iTunesArtwork]

        return Track(title: itunesTrack.name,
                     artist: itunesTrack.artist,
                     album: itunesTrack.album,
                     albumArtist: itunesTrack.albumArtist,
                     bitRate: itunesTrack.bitRate,
                     artworks: trackArtworks)
    }

}
