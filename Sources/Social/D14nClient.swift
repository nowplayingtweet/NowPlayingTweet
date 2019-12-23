/**
 *  D14nClient.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

protocol D14nClient: Client {

    typealias RegisterSuccess = (String, String) -> Void

}
