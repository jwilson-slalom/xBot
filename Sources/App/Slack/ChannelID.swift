//
//  ChannelID.swift
//  App
//
//  Created by Allen Humphreys on 3/5/19.
//

import Foundation

/// ChannelID is just a `String`, but typed APIs are great
class ChannelID {

    // I wonder if we should opt channels in via slash commands?
    #if DEBUG
    static let onTapNewBeerNotificationDestination = ChannelID(id: "CGL0T4GLC") // #channel-for-allen
    #else
    static let onTapNewBeerNotificationDestination = ChannelID(id: "CGL7CJ03W") // "water cooler"
    #endif

    let id: String

    init(id: String) {
        self.id = id
    }
}
