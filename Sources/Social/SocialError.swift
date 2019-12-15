/**
 *  SocialError.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation

enum SocialError: Error {

    case FailedAuthorize(String)
    case FailedVerify(String)
    case NotImplements(className: String, function: String)

}
