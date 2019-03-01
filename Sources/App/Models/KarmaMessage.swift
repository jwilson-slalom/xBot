//
//  KarmaMessage.swift
//  App
//
//  Created by Ryan Jones on 2/28/19.
//

import Foundation
import SlackKit

struct KarmaMessage {
    let user: String
    let karma: Int
}

extension KarmaMessage {

    private func messageColor() -> String {
        return karma >= 0 ? "#36a64f" : "#E8B122"
    }

    private func changed() -> String {
        if karma == 5 {
            return "elevated"
        } else if karma == -5 {
            return "plummeted"
        }
        return karma >= 0 ? "increased" : "decreased"
    }

    func defaultMessage() -> String {
        return "\(user)’s karma \(changed()) by \(karma)"
    }

    func slackAttachment(with newKarmaTotal: Int) -> Attachment {
//        let user = slackUser()
        return Attachment(attachment: ["fallback": defaultMessage(),
            "color": messageColor(),
//            "pretext": user,
            "text": "Karma \(changed()) to \(newKarmaTotal) \(emojiRelation(total: newKarmaTotal))"])
    }

    private func emojiRelation(total: Int) -> String {
        switch total {
        case -10 ... -1:
            return "👎"
        case -25 ... -11:
            return "🙊"
        case -50 ... -26:
            return "🥦"
        case -100 ... -51:
            return "💩"
        case -200 ... -101:
            return "🤮"
        case -300 ... -201:
            return "🙈"
        case -400 ... -301:
            return "☠️"
        case -401 ... -500:
            return "😈"
        case 0...10:
            return "👍"
        case 11...25:
            return "🤙"
        case 26...50:
            return "✅"
        case 51...100:
            return "🌟"
        case 101...200:
            return "💯"
        case 201...300:
            return "❤️"
        case 301...400:
            return "😎"
        case 401...500:
            return "🔥"
        default:
            return""
        }

    }

    func slackUser() -> String {
        return "<@\(user)>"
    }

    func karmaData() -> Karma {
        return Karma(id: user, karma: karma)
    }
}
