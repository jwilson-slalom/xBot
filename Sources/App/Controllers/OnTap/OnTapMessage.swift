//
//  OnTapMessage.swift
//  App
//
//  Created by Allen Humphreys on 3/4/19.
//

import SlackKit

struct OnTapMessage {

    static func newBeerAttachment(for tap: Tap, with beer: Beer?) -> Attachment {
        return beer.map { newBeerAttachment(for: tap, with: $0) } ?? Attachment(fallback: "Error", title: "Error")
    }

    static func newBeerAttachment(for tap: Tap, with beer: Beer) -> Attachment {

        return Attachment(attachment: ["fallback": "New beer",
                                       "color": "#36a64f",
                                       "title": "\(beer.name) is now on the \(tap == .left ? "Left" : "Right") Tap 🍻",
            "title_link": beer.untappdURL.absoluteString,
            "fields": [
                "value": beer.breweryName,
                "short": false
            ],
            "footer": "Brought to you by: _onTap"
            ]
        )
    }

    static func kegStatusAttachments(with kegSystem: KegSystem) -> [Attachment] {

        func beerText(_ beer: Beer?) -> String? {
            guard let beer = beer else { return nil }

            return beer.name + " - " + beer.breweryName
        }
        return
            [Attachment(attachment:
                [
                    "fallback": "Required plain-text summary of the attachment.",
                    "color": "#36a64f",
                    "pretext": "🍻",
                    "title": kegSystem.leftTap == nil ? "Offline" : "Left Tap",
                    "title_link": kegSystem.leftTap?.untappdURL.absoluteString as Any,
                    "text": beerText(kegSystem.leftTap) as Any
                ]),
             Attachment(attachment:
                [
                    "fallback": "Required plain-text summary of the attachment.",
                    "color": "#36a64f",
                    "title": kegSystem.rightTap == nil ? "Offline" : "Right Tap",
                    "title_link": kegSystem.rightTap?.untappdURL.absoluteString as Any,
                    "text": beerText(kegSystem.rightTap) as Any
                ])
        ]
    }
}
