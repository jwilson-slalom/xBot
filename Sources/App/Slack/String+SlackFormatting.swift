//
//  String+SlackFormatting.swift
//  App
//
//  Created by Allen Humphreys on 3/7/19.
//

import Foundation

extension String {

    func asSlackUserMention() -> String {
        // User IDs start with U
        if hasPrefix("<@") {
            return self
        }

        return "<@\(self)>"
    }

    func asSlackChannelMention() -> String {
        // Channel IDs start with C
        if hasPrefix("<#") {
            return self
        }

        return "<#\(self)>"
    }

    // IM IDs start with D
}
