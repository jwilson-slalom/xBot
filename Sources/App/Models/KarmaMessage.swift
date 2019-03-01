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
            "text": "Karma \(changed()) to \(newKarmaTotal)"])
    }

    func slackUser() -> String {
        return "<@\(user)>"
    }

    func karmaData() -> Karma {
        return Karma(id: user, karma: karma)
    }
}
