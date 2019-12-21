/**
 *  SocialError.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation

enum SocialError: Error {

    case FailedAuthorize(String)
    case FailedRevoke(String)
    case FailedVerify(String)
    case FailedPost(String)
    case NotImplements(className: String, function: String)

}

extension SocialError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .NotImplements(let className, let function):
            return "Not implements \(className).\(function)"
        case .FailedAuthorize(let message):
            return message
        case .FailedRevoke(let message):
            return message
        case .FailedVerify(let message):
            return message
        case .FailedPost(let message):
            return message
        }
    }

}
