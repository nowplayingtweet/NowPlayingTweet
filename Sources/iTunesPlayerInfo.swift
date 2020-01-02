/**
 *  iTunesPlayerInfo.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
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

        var artwork: Data? {
            return self.artworks.isEmpty ? nil : self.artworks[0].rawData
        }
    }

    var currentTrack: Track? {
        guard let itunes = self.itunes
            , let currentTrack = itunes.currentTrack else {
            return nil
        }

        if currentTrack.exists?() ?? false {
            return self.convert(from: currentTrack)
        } else {
            return nil
        }
    }

    private var itunes: iTunesApplication? {
        if #available(macOS 10.14, *) {
            if self.itunesState == noErr {
                return SBApplication(bundleIdentifier: "com.apple.iTunes")
            }

            return nil
        } else {
            if !self.isRunning {
                return nil
            }

            return SBApplication(bundleIdentifier: "com.apple.iTunes")
        }
    }

    @available(macOS 10.14, *)
    private var itunesState: OSStatus {
        let targetAppEventDescriptor: NSAppleEventDescriptor = NSAppleEventDescriptor(bundleIdentifier: "com.apple.iTunes")
        let status = AEDeterminePermissionToAutomateTarget(targetAppEventDescriptor.aeDesc, typeWildCard, typeWildCard, true)
        return status
    }

    var hasPermission: Bool {
        if #available(macOS 10.14, *) {
            return self.itunesState != OSStatus(errAEEventNotPermitted)
        } else {
            return true
        }
    }

    var isRunning: Bool {
        if #available(macOS 10.14, *) {
            return self.itunesState != OSStatus(procNotFound)
        } else {
            let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.iTunes")

            return !runningApps.isEmpty
        }
    }

    var existsTrack: Bool {
        return self.currentTrack != nil
    }

    private func convert(from itunesTrack: iTunesTrack) -> Track {
        let trackArtworks: [iTunesArtwork] = itunesTrack.artworks?() ?? []

        return Track(title: itunesTrack.name,
                     artist: itunesTrack.artist,
                     album: itunesTrack.album,
                     albumArtist: itunesTrack.albumArtist,
                     bitRate: itunesTrack.bitRate,
                     artworks: trackArtworks)
    }

}
