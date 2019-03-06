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

        let kegSystem = KegSystem(leftTap: OnTapMemory.leftBeer, rightTap: OnTapMemory.rightBeer)
        let attachments = OnTapMessage.kegStatusAttachments(with: kegSystem)
        let response = message.response(attachments: attachments)

        try slack.send(message: response)
    }

    func notifySlackOfNewBeer(_ beer: Beer?, on tap: Tap) throws {
        let message = Message(text: "", channelID: .onTapNewBeerNotificationDestination)
        message.attachments = [OnTapMessage.newBeerAttachment(for: tap, with: beer)]

        try slack.send(message: message)
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
