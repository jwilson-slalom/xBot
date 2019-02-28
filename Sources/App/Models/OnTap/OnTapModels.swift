//
//  OnTapModels.swift
//  App
//
//  Created by Allen Humphreys on 2/28/19.
//

import Foundation
import Vapor

struct Beer: Codable {
    let name = "A Beers Name"
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
