//
//  AppTestCase.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/12/19.
//

@testable import App
import Vapor
import XCTest

extension XCTestCase {
    func emptyRequest(using app: Application) -> Request {
        let method = HTTPMethod.GET
        let url = URL(string: "path")
        let headers = HTTPHeaders()

        let request = HTTPRequest(method: method, url: url!, headers: headers)
        let wrappedRequest = Request(http: request, using: app)

        return wrappedRequest
    }

    func validatedSlackRequest(using app: Application) -> Request {
        let method = HTTPMethod.GET
        let url = URL(string: "path")
        var headers = HTTPHeaders()
        headers.add(name: HTTPHeaderName.slackTimestamp, value: "timestamp")
        headers.add(name: HTTPHeaderName.slackSignature, value: "v0=2205e87280007c5c5dd9c08ef28f8de833b206bdfd9234d0f67f7054ec0b5acd")

        var request = HTTPRequest(method: method, url: url!, headers: headers)
        request.contentType = MediaType.urlEncodedForm
        request.body = HTTPBody(string: "body")

        let wrappedRequest = Request(http: request, using: app)
        return wrappedRequest
    }
}

extension Application {
    static func testable(envArgs: [String]? = nil) throws -> Application {
        let config = Config.default()
        let services = Services.default()
        var env = Environment.testing

        if let environmentArgs = envArgs {
            env.arguments = environmentArgs
        }

        let app = try Application(config: config, environment: env,services: services)

        return app
    }
}

