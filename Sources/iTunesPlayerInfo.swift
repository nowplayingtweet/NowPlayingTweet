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
        let runningApps = NSWorkspace.shared.runningApplications

        let appIDs = runningApps.map { $0.bundleIdentifier }

        return appIDs.first(where: { $0 == "com.apple.iTunes" }) != nil
    }

    var existTrack: Bool {
        return self.currentTrack != nil
    }

    init() {
        self.updateTrack()
    }

    func updateTrack() {
        if !self.isRunningiTunes {
            self.cleanTrack()
            self.iTunes = nil
            return
        }

        guard let ituens: iTunesApplication = self.iTunes ?? ScriptingUtilities.application(name: "iTunes") as? iTunesApplication else {
            self.cleanTrack()
            return
        }

        let existsCurrentTrack: () -> Bool = ituens.currentTrack?.exists ?? {
            return false
        }

        if existsCurrentTrack() {
            self.convert(from: ituens.currentTrack!)
        }
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
