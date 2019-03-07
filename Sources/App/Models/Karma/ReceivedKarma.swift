//
//  KarmaMessage.swift
//  App
//
//  Created by Ryan Jones on 2/28/19.
//

import Foundation
import SlackKit

struct ReceivedKarma {
    let user: String
    let count: Int
}

extension ReceivedKarma: Equatable { }

extension ReceivedKarma {

    func karmaData() -> KarmaStatus {
        return KarmaStatus(id: user, count: count)
    }
}
