//
//  OnTapModels.swift
//  App
//
//  Created by Allen Humphreys on 2/28/19.
//

import Foundation
import FluentSQLite
import Vapor

enum Tap: String, Fluent.ID, Parameter {
    static func resolveParameter(_ parameter: String, on container: Container) throws -> Tap {
        if let decoded = Tap(rawValue: parameter) {
            return decoded
        }
        throw Abort(.internalServerError)
    }

    typealias ResolvedParameter = Tap

    case left, right
}

struct Beer: Content, SQLiteStringModel, Migration {

    var id: String?
    var name: String
    var breweryName: String
}

extension Beer: RequestDecodable {

    static func decode(from req: Request) throws -> EventLoopFuture<Beer> {
        return try req.content.decode(Beer.self)
    }
}

extension Beer: ResponseEncodable {

    func encode(for req: Request) throws -> EventLoopFuture<Response> {
        let data = try! JSONEncoder().encode(self)
        let response = req.response(data as LosslessHTTPBodyRepresentable)
        return response.future(response)
    }
}
