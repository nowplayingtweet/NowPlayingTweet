/**
 *  iTunesPlayerInfo.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import AppKit
import iTunesScripting

class iTunesPlayerInfo {

    var title: String?

    var artist: String?

    var album: String?

    var albumArtist: String?

    var bitRate: Int?

    var artworks: [iTunesArtwork]

    var artwork: NSImage?

    init(_ itunesTrack: iTunesTrack) {
        let trackArtworks: [iTunesArtwork] = itunesTrack.artworks!() as! [iTunesArtwork]
        self.artworks = trackArtworks

        self.artwork = self.artworks[0].data

        self.title = itunesTrack.name

        self.artist = itunesTrack.artist

        self.album = itunesTrack.album

        self.albumArtist = itunesTrack.albumArtist

        self.bitRate = itunesTrack.bitRate
    }

}
