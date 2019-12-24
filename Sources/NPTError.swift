/**
 *  NPTError.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation

enum NPTError: Error {

    case NotLaunchediTunes
    case HasNotPermission
    case NotExistsTrack
    case NotLogin
    case Unknown(String)

}
