//
//  Karma.swift
//  App
//
//  Created by John Welch on 2/28/19.
//

import Foundation
import FluentSQLite
import Vapor

/// Associate a karma (rating) with a unique entity
final class Karma: SQLiteStringModel {
    var id: String?
    var karma: Int

	init(id: String?, karma: Int = 0) {
        self.id = id
        self.karma = karma
    }
}

/// Allows `Karma` to be used as a dynamic migration.
extension Karma: Migration { }

/// Allows `Karma` to be encoded to and decoded from HTTP messages.
extension Karma: Content { }

/// Allows `Karma` to be used as a dynamic parameter in route definitions.
extension Karma: Parameter { }
