//
//  OnTapController+SlackResponder.swift
//  App
//
//  Created by Allen Humphreys on 3/4/19.
//

import Foundation

extension OnTapController: SlackResponder {

    func handle(message: Message) throws {
        guard let botUser = slack.botUser else { return }
        guard let directedTo = message.text.userIDMentionedBeforeAnyOtherContent() else { return }
        guard botUser.id == directedTo else { return }

        // Keyword response
        guard message.text.contains("beer") || message.text.contains("tap") else { return }

        try slack.send(message: OnTapMessage(respondingTo: message, kegSystem: OnTapMemory.kegSystem))
    }

    func notifySlackOfNewBeer(_ beer: Beer?, on tap: Tap) throws {
        guard let beer = beer else { return } // No message for when a tap goes offline, I don't think anyone cares

        try slack.send(message: OnTapMessage(newBeer: beer, tap: tap))
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
