//
//  OnTapModels.swift
//  App
//
//  Created by Allen Humphreys on 2/28/19.
//

import Foundation
import FluentSQLite
import Vapor

enum Tap: String, Parameter {

    static func resolveParameter(_ parameter: String, on container: Container) throws -> Tap {
        if let decoded = Tap(rawValue: parameter) {
            return decoded
        }
        throw Abort(.internalServerError)
    }

    typealias ResolvedParameter = Tap

    case left, right
}

struct Beer: Content {

    var id: String
    var untappdID: Double
    var name: String
    var breweryName: String
    var untappdURL: URL
}

struct KegSystem: Content {
    var leftTap: Beer?
    var rightTap: Beer?
}
