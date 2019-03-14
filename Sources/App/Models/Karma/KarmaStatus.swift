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
    var type: String

    init(id: String?, count: Int, type: String = KarmaStatusType.user.rawValue) {
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

extension KarmaStatus: Equatable {
    static func == (lhs: KarmaStatus, rhs: KarmaStatus) -> Bool {
        return lhs.id == rhs.id && lhs.count == lhs.count && lhs.type == rhs.type
    }
}

enum KarmaStatusType: String {
    case user = "USER"
    case other = "OTHER"
    // channel, etc.
}

