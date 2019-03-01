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

    func slackUser() -> String {
        return "<@\(user)>"
    }

    func karmaData() -> Karma {
        return Karma(id: user, karma: karma)
    }
}
