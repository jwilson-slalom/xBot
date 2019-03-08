//
//  OnTapMessage.swift
//  App
//
//  Created by Allen Humphreys on 3/4/19.
//

import SlackKit

class OnTapResponse: SlackKitResponse {

    init(to incomingMessage: SlackKitIncomingMessage, kegSystem: KegSystem) {
        super.init(to: incomingMessage, attachments: OnTapResponse.kegStatusAttachments(with: kegSystem))
    }

    private static func kegStatusAttachments(with kegSystem: KegSystem) -> [Attachment] {

        func beerText(_ beer: Beer?) -> String {
            guard let beer = beer else { return "Offline" }

            let abvSignal = beer.abv > 7.5 ? "⚠️ " : ""
            return """
                    *<\(beer.untappdURL.absoluteString)|\(beer.name)>*
                    \(beer.breweryName)
                    \(beer.style)
                    \(abvSignal)\(beer.abv)% abv - \(Int(beer.ibu)) ibu
                    """
        }

        var fallbackText = ""
        if let leftBeer = kegSystem.leftBeer {
            fallbackText += "Left: \(leftBeer.name)"
        }
        if let rightBeer = kegSystem.rightBeer {
            fallbackText.isNotEmpty ? fallbackText += ", " : ()
            fallbackText += "Right: \(rightBeer.name)"
        }

        let attachment: [String: Any] = [
            "fallback": fallbackText,
            "color": "00FFFF",
            "pretext": "Here's what's _onTap! 🍻 <#\(ChannelID.onTapNewBeerNotificationDestination.id)>",
            "mrkdwn_in": ["fields"],
            "fields": [
                [
                    "value": beerText(kegSystem.leftBeer),
                    "short": true
                ],
                [
                    "value": beerText(kegSystem.rightBeer),
                    "short": true
                ]
            ],
            "footer": "Updated",
            "ts": Int(kegSystem.updated.timeIntervalSince1970)
        ]

        return [Attachment(attachment: attachment)]
    }
}

class OnTapNewBeerMessage: SlackKitMessage {

    convenience init(newBeer beer: Beer, tap: Tap) {
        self.init(text: "", channelID: .onTapNewBeerNotificationDestination)

        attachments = [OnTapNewBeerMessage.newBeerAttachment(for: tap, with: beer)]
    }

    private static func newBeerAttachment(for tap: Tap, with beer: Beer) -> Attachment {

        let fallback = "🍻 \(beer.name) from \(beer.breweryName) is now on tap in the Capacitor Café"
        let text = "🍻 <\(beer.untappdURL.absoluteString)|*\(beer.name)*> from _\(beer.breweryName)_ is now on tap in the Capacitor Café"

        let attachment: [String: Any] = [
            "fallback": fallback,
            "color": "#00ffff",
            "mrkdwn_in": ["text"],
            "text": text
        ]
        return Attachment(attachment: attachment)
    }
}
