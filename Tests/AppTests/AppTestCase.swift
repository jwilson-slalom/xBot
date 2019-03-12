//
//  AppTestCase.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/12/19.
//

@testable import App
import Vapor
import XCTest

class AppTestCase: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        try? app.syncShutdownGracefully()
    }

    func emptyRequest() -> Request {
        let method = HTTPMethod.GET
        let url = URL(string: "path")
        let headers = HTTPHeaders()

        let request = HTTPRequest(method: method, url: url!, headers: headers)
        let wrappedRequest = Request(http: request, using: app)

        return wrappedRequest
    }

    func createStatusRequest(status: KarmaStatus) -> Request {
        let method = HTTPMethod.GET
        let url = URL(string: "path")
        let headers = HTTPHeaders()

        let request = HTTPRequest(method: method, url: url!, headers: headers)
        let wrappedRequest = Request(http: request, using: app)
        try! wrappedRequest.content.encode(status)
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

