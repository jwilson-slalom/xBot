//
//  KarmaMessage.swift
//  App
//
//  Created by Ryan Jones on 2/28/19.
//

import Foundation
import SlackKit

struct KarmaResponse: Codable {
    let attachments: [KarmaAttachment]
}

struct KarmaAttachment: Codable {
    let fallback: String
    let color: String
    let text: String
}

struct KarmaMessage {
    let user: String
    let count: Int
}

extension KarmaMessage: Equatable { }

extension KarmaMessage {

    private func messageColor() -> String {
        return count >= 0 ? "#36a64f" : "#E8B122"
    }

    private func changed() -> String {
        if count == 5 {
            return "elevated"
        } else if count == -5 {
            return "plummeted"
        }
        return count >= 0 ? "increased" : "decreased"
    }

    func defaultMessage() -> String {
        return "\(slackUser())’s karma \(changed()) by \(count)"
    }

    func slackAttachment(with newKarmaTotal: Int) -> Attachment {
//        let user = slackUser()
        return Attachment(attachment: ["fallback": defaultMessage(),
            "color": messageColor(),
//            "pretext": user,
            "text": "Karma \(changed()) to \(newKarmaTotal) \(emojiRelation(total: newKarmaTotal))"])
    }

    func slackAttachment() -> Attachment {
        return Attachment(attachment: ["fallback": defaultMessage(),
                                       "color": messageColor(),
                                       "text": currentCountText()])
    }

    func karmaAttachment() -> KarmaAttachment {
        return KarmaAttachment(fallback: defaultMessage(),
                               color: messageColor(),
                               text: currentCountText())
    }

    private func currentCountText() -> String {
        return "\(slackUser()) has \(count) karma \(emojiRelation(total: count))"
    }

    private func emojiRelation(total: Int) -> String {
        let lessThanZero = total < 0
        if total < 0 {
            switch lessThanZero {
            case (-10 ..< 0).contains(total):
                return "👎"
            case (-25 ..< -10).contains(total):
                return "🙊"
            case (-50 ..< -25).contains(total):
                return "🥦"
            case (-100 ..< -50).contains(total):
                return "💩"
            case (-200 ..< -100).contains(total):
                return "🤮"
            case (-300 ..< -200).contains(total):
                return "🙈"
            case (-400 ..< -300).contains(total):
                return "☠️"
            case (Int.min ..< 400).contains(total):
                return "😈"
            default:
                return ""
            }
        }
        switch total {
        case 0..<10:
            return "👍"
        case 10..<25:
            return "🤙"
        case 25..<50:
            return "✅"
        case 50..<100:
            return "🌟"
        case 100..<200:
            return "💯"
        case 200..<300:
            return "❤️"
        case 300..<400:
            return "😎"
        case 400..<500:
            return "🔥"
        default:
            return""
        }

    }

    func slackUser() -> String {
        return "<@\(user)>"
    }

    func statusData() -> KarmaStatus {
        return KarmaStatus(id: user, count: count)
    }
}
