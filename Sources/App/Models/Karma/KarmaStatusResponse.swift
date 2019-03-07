//
//  KarmaStatusResponse.swift
//  App
//
//  Created by Allen Humphreys on 3/7/19.
//

import Foundation
import struct SlackKit.Attachment

class KarmaStatusResponse: SlackKitResponse {
    enum CodingKeys: String, CodingKey {
        case text, attachments
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(attachments, forKey: .attachments)
    }

    init(forSlashCommandWithKarmaStatuses statuses: [KarmaStatus]) {
        super.init(inResponseTo: nil, text: "",
                   attachments: statuses.map { KarmaStatusResponse.slashCommandSlackAttachment(karmaStatus: $0) })
    }

    init(karmaGivingMessage incomingMessage: SlackKitIncomingMessage, receivedKarma: ReceivedKarma, karmaStatus: KarmaStatus) {
        super.init(inResponseTo: incomingMessage,
                   text: receivedKarma.user.slackMention(),
                   attachments: [KarmaStatusResponse.slackAttachment(with: receivedKarma, totalKarma: karmaStatus.count)])
    }
}

extension KarmaStatusResponse {

    static func defaultMessage(karma: ReceivedKarma) -> String {
        return "\(karma.user)’s karma \(changed(karma: karma)) by \(karma.count)"
    }

    private static func messageColor(karmaCount: Int) -> String {
        return karmaCount >= 0 ? "#36a64f" : "#E8B122"
    }

    private static func changed(karma: ReceivedKarma) -> String {
        if karma.count == 5 {
            return "elevated"
        } else if karma.count == -5 {
            return "plummeted"
        }
        return karma.count >= 0 ? "increased" : "decreased"
    }

    static func slackAttachment(with receivedKarma: ReceivedKarma, totalKarma: Int) -> Attachment {
        return Attachment(attachment: ["fallback": defaultMessage(karma: receivedKarma),
                                       "color": messageColor(karmaCount: receivedKarma.count),
            "text": "Karma \(changed(karma: receivedKarma)) to \(totalKarma) \(emojiRelation(total: totalKarma))"])
    }

    static func slashCommandSlackAttachment(karmaStatus: KarmaStatus) -> Attachment {
        return Attachment(attachment: ["fallback": currentCountText(karmaStatus: karmaStatus, fallback: true),
                                       "color": messageColor(karmaCount: karmaStatus.count),
                                       "text": currentCountText(karmaStatus: karmaStatus, fallback: false)])
    }

    private static func currentCountText(karmaStatus: KarmaStatus, fallback: Bool) -> String {
        return "\((fallback ? karmaStatus.id : karmaStatus.id?.slackMention()) ?? "Something") has \(karmaStatus.count) karma \(emojiRelation(total: karmaStatus.count))"
    }

    private static func emojiRelation(total: Int) -> String {
        switch total {
        case 400...Int.max:
            return "🔥"
        case 300..<400:
            return "😎"
        case 200..<300:
            return "❤️"
        case 100..<200:
            return "💯"
        case 50..<100:
            return "🌟"
        case 25..<50:
            return "✅"
        case 10..<25:
            return "🤙"
        case 0..<10:
            return "👍"
        case -10..<0:
            return "👎"
        case -25 ..< -10:
            return "🙊"
        case -50 ..< -25:
            return "🥦"
        case -100 ..< -50:
            return "💩"
        case -200 ..< -100:
            return "🤮"
        case -300 ..< -200:
            return "🙈"
        case -400 ..< -300:
            return "☠️"
        case Int.min ..< -400:
            return "😈"
        default:
            return ""
        }
    }
}
