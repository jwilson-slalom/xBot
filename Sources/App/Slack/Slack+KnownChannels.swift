//
//  Slack+KnownChannels.swift
//  App
//
//  Created by Allen Humphreys on 3/4/19.
//

import SlackKit

extension Channel {
    // I wonder if we should opt channels in via slash commands?
    #if DEBUG
    static let onTapNewBeerNotificationDestination = "CGL0T4GLC" // #channel-for-allen
    #else
    static let onTapNewBeerNotificationDestination = "CGL7CJ03W" // "water cooler"
    #endif
}
