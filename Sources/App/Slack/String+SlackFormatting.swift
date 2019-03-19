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

    func userIDMentionedBeforeAnyOtherContent() -> String? {
        let userIdString = "^\\s*<@([\\w]{9})(?:\\|{1}[^>]+){0,1}?>"

        return (try? NSRegularExpression(pattern: userIdString))?
            .firstMatch(in: self, options: [], range: NSRange(startIndex..<endIndex, in: self))
            .flatMap { result in
                Range(result.range(at: 1), in: self).map { String(self[$0]) }
        }
    }
}
