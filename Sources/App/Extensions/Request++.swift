//
//  Request++.swift
//  App
//
//  Created by Allen Humphreys on 3/9/19.
//

import Vapor

extension Request {

    func response(status: HTTPStatus) -> Future<Response> {
        return response().encode(status: status, for: self)
    }

    func response(status: HTTPStatus) -> Response {
        return response(http: .init(status: status))
    }

    func response<C>(content: C) throws -> Response where C: Content {
        let response = self.response()
        try response.content.encode(content)
        return response
    }
}
