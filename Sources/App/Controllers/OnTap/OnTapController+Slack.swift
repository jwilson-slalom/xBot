//
//  OnTapController+SlackResponder.swift
//  App
//
//  Created by Allen Humphreys on 3/4/19.
//

import Foundation
import struct SlackKit.User

extension OnTapController: SlackResponder {

    func handle(incomingMessage: SlackKitIncomingMessage, forBotUser botUser: User) throws {
        guard let directedTo = incomingMessage.text.userIDMentionedBeforeAnyOtherContent() else { return }
        guard botUser.id == directedTo else { return }

        // Keyword response
        guard incomingMessage.text.contains("beer") || incomingMessage.text.contains("tap") else { return }

        try slack.send(message: OnTapResponse(to: incomingMessage, kegSystem: OnTapMemory.kegSystem))
    }

    func notifySlackOfNewBeer(_ beer: Beer?, on tap: Tap) throws {
        guard let beer = beer else { return } // No message for when a tap goes offline, I don't think anyone cares

        try slack.send(message: OnTapNewBeerMessage(newBeer: beer, tap: tap))
    }
}

private extension String {

    func userIDMentionedBeforeAnyOtherContent() -> String? {

        return (try? NSRegularExpression(pattern: "^\\s*<@([\\w\\d]+)>"))?
            .firstMatch(in: self, options: [], range: NSRange(startIndex..<endIndex, in: self))
            .flatMap { result in
                Range(result.range(at: 1), in: self).map { String(self[$0]) }
            }
    }
}
