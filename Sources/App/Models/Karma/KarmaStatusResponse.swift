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
        super.init(to: nil, text: "",
                   attachments: statuses.map { KarmaStatusResponse.slashCommandSlackAttachment(karmaStatus: $0) })
    }

    init(forKarmaAdjustingMessage incomingMessage: SlackKitIncomingMessage, receivedKarma: KarmaAdjustment, statusAfterChange karmaStatus: KarmaStatus) {
        super.init(to: incomingMessage,
                   text: "",
                   attachments: [KarmaStatusResponse.slackAttachment(with: receivedKarma, totalKarma: karmaStatus.count, userId: receivedKarma.user.asSlackUserMention())])
    }

    init(forLeaderboardCommandStatuses statuses: [KarmaStatus]) {
        super.init(to: nil, text: "Karma Leaderboard",
                   attachments: [KarmaStatusResponse.slackLeaderboardAttachment(with: statuses)])
    }
}

extension KarmaStatusResponse {

    static func defaultMessage(karma: KarmaAdjustment) -> String {
        return "\(karma.user)’s karma \(changed(karma: karma)) by \(karma.count)"
    }

    private static func messageColor(karmaCount: Int) -> String {
        return karmaCount >= 0 ? "#36a64f" : "#E8B122"
    }

    private static func changed(karma: KarmaAdjustment) -> String {
        if karma.count == 5 {
            return "elevated"
        } else if karma.count == -5 {
            return "plummeted"
        }
        return karma.count >= 0 ? "increased" : "decreased"
    }

    static func slackAttachment(with receivedKarma: KarmaAdjustment, totalKarma: Int, userId: String) -> Attachment {
        return Attachment(attachment: ["fallback": defaultMessage(karma: receivedKarma),
                                       "color": messageColor(karmaCount: receivedKarma.count),
                                       "text": "\(userId) (\(emojiRelation(total: totalKarma))): Karma \(changed(karma: receivedKarma)) to \(totalKarma)"])
    }

    static func slashCommandSlackAttachment(karmaStatus: KarmaStatus) -> Attachment {
        return Attachment(attachment: ["fallback": currentCountText(karmaStatus: karmaStatus, fallback: true),
                                       "color": messageColor(karmaCount: karmaStatus.count),
                                       "text": currentCountText(karmaStatus: karmaStatus, fallback: false)])
    }

    static func slackLeaderboardAttachment(with statuses: [KarmaStatus]) -> Attachment {
        var fields: [[String:Any]] = [["title": "User", "short": true], ["title": "Karma", "short": true]]

        statuses.forEach { status in
            fields.append(["value": "\(status.id?.asSlackUserMention() ?? "") (\(emojiRelation(total: status.count)))", "short": true])
            fields.append(["value": status.count.description, "short": true])
        }

        return Attachment(attachment: [
            "fallback": "Leaderboard",
            "title": "Leaderboard",
            "pretext": "The users with the most karma are:",
            "fields": fields
            ])
    }

    private static func currentCountText(karmaStatus: KarmaStatus, fallback: Bool) -> String {
        return "\((fallback ? karmaStatus.id : karmaStatus.id?.asSlackUserMention()) ?? "Something") (\(emojiRelation(total: karmaStatus.count))): \(karmaStatus.count) karma "
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
