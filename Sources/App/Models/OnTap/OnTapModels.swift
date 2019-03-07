//
//  OnTapModels.swift
//  App
//
//  Created by Allen Humphreys on 2/28/19.
//

import Foundation
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
    let untappdID: Double
    let name: String
    let breweryName: String
    let untappdURL: URL
    let style: String
    let abv: Double
    let ibu: Double
}

struct KegSystem: Content {
    enum CodingKeys: String, CodingKey {
        case leftBeer, rightBeer
    }

    var leftBeer: Beer?
    var rightBeer: Beer?

    var updated = Date.distantPast
}
