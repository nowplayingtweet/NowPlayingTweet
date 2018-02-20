/**
 *  iTunesPlayerInfo.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import iTunesScripting
import ScriptingUtilities

class iTunesPlayerInfo {

    struct Track {
        let title: String?

        let artist: String?

        let album: String?

        let albumArtist: String?

        let bitRate: Int?

        let artworks: [iTunesArtwork]?

        var artwork: NSImage? {
            return self.artworks?[0].data
        }
    }

    private var iTunes: iTunesApplication?

    var currentTrack: iTunesPlayerInfo.Track?

    var isRunningiTunes: Bool {
        return self.checkRunningiTunes()
    }

    var existTrack: Bool {
        return self.currentTrack != nil
    }

    init() {
        self.updateTrack()
    }

    func updateTrack() {
        if !self.checkRunningiTunes() {
            self.cleanTrack()
            self.iTunes = nil
            return
        }

        if self.iTunes == nil {
            self.iTunes = ScriptingUtilities.application(name: "iTunes") as? iTunesApplication
            //self.iTunes = ScriptingUtilities.application(bundleIdentifier: "com.apple.iTunes") as? iTunesApplication
        }

        let existTrack = self.iTunes?.currentTrack?.exists!()

        if existTrack! {
            self.convert(from: (self.iTunes?.currentTrack)!)
        } else {
            self.cleanTrack()
        }
    }

    private func checkRunningiTunes() -> Bool {
        let runningApps = NSWorkspace.shared.runningApplications

        let regularApps = runningApps.filter {
            $0.activationPolicy == NSApplication.ActivationPolicy.regular
        }
        let appIDs = regularApps.map { $0.bundleIdentifier }

        return appIDs.first(where: { $0 == "com.apple.iTunes" }) != nil
    }

    private func cleanTrack() {
        self.currentTrack = nil
    }

    private func convert(from itunesTrack: iTunesTrack) {
        let trackArtworks: [iTunesArtwork] = itunesTrack.artworks!() as! [iTunesArtwork]

        self.currentTrack = Track(title: itunesTrack.name,
                                  artist: itunesTrack.artist,
                                  album: itunesTrack.album,
                                  albumArtist: itunesTrack.albumArtist,
                                  bitRate: itunesTrack.bitRate,
                                  artworks: trackArtworks)
    }

}
