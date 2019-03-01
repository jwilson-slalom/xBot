//
//  KarmaMessage.swift
//  App
//
//  Created by Ryan Jones on 2/28/19.
//

import Foundation

struct KarmaMessage {
    let user: String
    let karma: Int
}

extension KarmaMessage {

    private func messageColor() -> String {
        return karma >= 0 ? "#36a64f" : "#E8B122"
    }

    private func crease() -> String {
        return karma >= 0 ? "increased" : "decreased"
    }

    func slackRepsonseJSON() -> String {
        let user = slackUser()
        let string = """
        {
            "attachments": [
                {
                    "fallback": "\(user)’s karma \(crease()) by \(karma)",
                    "color": "\(messageColor())",
                    "pretext": "\(user)",
                    "text": "\(user)’s karma \(crease()) by \(karma)"
                }
            ]
        }
        """
        return string
    }

    func slackUser() -> String {
        return "<@\(user)>"
    }

    func karmaData() -> Karma {
        return Karma(id: user, karma: karma)
    }
}
