//
//  OnTapController+SlackResponder.swift
//  App
//
//  Created by Allen Humphreys on 3/4/19.
//

import SlackKit

extension OnTapController: SlackResponder {

    var eventTypes: [EventType] { return [.message] }

    func handleEvent(event: Event) {

        if event.message?.text?.contains("beer") ?? false {

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
