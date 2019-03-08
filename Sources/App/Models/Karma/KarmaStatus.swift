//
//  Karma.swift
//  App
//
//  Created by John Welch on 2/28/19.
//

import Foundation
import FluentPostgreSQL
import Vapor

/// Associate a karma (rating) with a unique entity
final class KarmaStatus: PostgreSQLStringModel {
    var id: String?
    
    var count: Int
    var type: StatusType

    init(id: String?, count: Int, type: StatusType = .user) {
        self.id = id
        self.count = count
        self.type = type
    }
}

/// Allows `KarmaStatus` to be used as a dynamic migration.
extension KarmaStatus: Migration { }

/// Allows `KarmaStatus` to be encoded to and decoded from HTTP messages.
extension KarmaStatus: Content { }

/// Allows `KarmaStatus` to be used as a dynamic parameter in route definitions.
extension KarmaStatus: Parameter { }

enum StatusType: String, Codable {
    case user = "USER"
    case other = "OTHER"
    // channel, etc.
}

// Required in order to have StatusType be used in Migrations
extension StatusType: ReflectionDecodable {
    static func reflectDecoded() throws -> (StatusType, StatusType) {
        return (.user, .other)
    }
}

