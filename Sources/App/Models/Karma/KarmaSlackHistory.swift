//
//  KarmaSlackHistory.swift
//  App
//
//  Created by Jacob Wilson on 3/7/19.
//

import Foundation
import FluentSQLite
import Vapor

/// Captures a karma interaction from Slack
final class KarmaSlackHistory: SQLiteModel {
    var id: Int?

    var karmaCount: Int
    var fromUser: String
    var karmaReceiver: String
    var channel: String

    init(id: Int? = nil,
         karmaCount: Int,
         fromUser: String,
         karmaReceiver: String,
         channel: String) {

        self.id = id
        self.karmaCount = karmaCount
        self.fromUser = fromUser
        self.karmaReceiver = karmaReceiver
        self.channel = channel
    }
}

/// Allows `KarmaSlackHistory` to be used as a dynamic migration.
extension KarmaSlackHistory: Migration { }

/// Allows `HistoricalKarma` to be encoded to and decoded from HTTP messages.
extension KarmaSlackHistory: Content { }

/// Allows `HistoricalKarma` to be used as a dynamic parameter in route definitions.
extension KarmaSlackHistory: Parameter { }
