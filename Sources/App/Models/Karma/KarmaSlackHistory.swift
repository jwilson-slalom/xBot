//
//  KarmaSlackHistory.swift
//  App
//
//  Created by Jacob Wilson on 3/7/19.
//

import Foundation
import FluentPostgreSQL
import Vapor

/// Captures a karma interaction from Slack
final class KarmaSlackHistory: PostgreSQLModel {
    var id: Int?

    var karmaCount: Int
    var karmaReceiver: String
    var karmaSender: String
    var inChannel: String

    init(id: Int? = nil,
         karmaCount: Int,
         karmaReceiver: String,
         karmaSender: String,
         inChannel: String) {

        self.id = id
        self.karmaCount = karmaCount
        self.karmaReceiver = karmaReceiver
        self.karmaSender = karmaSender
        self.inChannel = inChannel
    }
}

/// Allows `KarmaSlackHistory` to be used as a dynamic migration.
extension KarmaSlackHistory: Migration { }

/// Allows `HistoricalKarma` to be encoded to and decoded from HTTP messages.
extension KarmaSlackHistory: Content { }

/// Allows `HistoricalKarma` to be used as a dynamic parameter in route definitions.
extension KarmaSlackHistory: Parameter { }

extension KarmaSlackHistory: Equatable {
    static func == (lhs: KarmaSlackHistory, rhs: KarmaSlackHistory) -> Bool {
        return lhs.id == rhs.id &&
                lhs.karmaCount == rhs.karmaCount &&
                lhs.fromUser == rhs.fromUser &&
                lhs.karmaReceiver == rhs.karmaReceiver &&
                lhs.channel == rhs.channel
    }
}

