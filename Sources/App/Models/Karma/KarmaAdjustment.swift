//
//  KarmaMessage.swift
//  App
//
//  Created by Ryan Jones on 2/28/19.
//

import Foundation
import SlackKit

struct KarmaAdjustment {
    let user: String
    let count: Int
}

extension KarmaAdjustment: Equatable { }
