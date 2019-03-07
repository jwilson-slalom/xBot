//
//  Leaderboard.swift
//  App
//
//  Created by John Welch on 3/1/19.
//

import Foundation
import Vapor

struct Leaderboard: Content {
//    func encode(for req: Request) throws -> EventLoopFuture<Response> {
//        return try req.response().content.encode(self, as: .json)
//
//        req.response()
//    }

    let text: String

    init(text: String) {
        self.text = text
    }
}
