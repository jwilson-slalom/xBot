//
//  OnTapController+SlackResponder.swift
//  App
//
//  Created by Allen Humphreys on 3/4/19.
//

import Foundation
import SlackKit

extension OnTapController: SlackResponder {

    var eventTypes: [EventType] { return [.message] }

    func handleEvent(event: Event) {
        guard let messageText = event.message?.text else { return }
        guard let botUser = slack.botUser else { return }
        guard let directedTo = messageText.userIDMentionedBeforeAnyOtherContent() else { return }
        guard botUser.id == directedTo else { return }

        if messageText.contains("beer") || messageText.contains("tap") {

            do {
                try slack.sendMessage(
                    text: "",
                    channelId: event.channel!.id!,
                    attachments: OnTapMessage.kegStatusAttachments(with: KegSystem(leftTap: OnTapMemory.leftBeer, rightTap: OnTapMemory.rightBeer))
                )
            } catch {
                log.error("Failed to send slack message: \(error)")
            }
        }
    }

    func notifySlackOfNewBeer(_ beer: Beer?, on tap: Tap) throws {
        try slack.sendMessage(
            text: "",
            channelId: Channel.onTapNewBeerNotificationDestination,
            attachments: [OnTapMessage.newBeerAttachment(for: tap, with: beer)]
        )
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
