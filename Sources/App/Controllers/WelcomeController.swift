//
//  WelcomeController.swift
//  App
//
//  Created by Allen Humphreys on 3/7/19.
//

import Vapor

final class WelcomeController: RouteCollection {

    let slack: Slack
    let log: Logger

    init(slackClient: Slack, logger: Logger) {
        self.slack = slackClient
        self.log = logger
    }

    func boot(router: Router) throws {
        // No HTTP routes, we just use this to get created
    }
}

extension WelcomeController: ServiceType {

    static func makeService(for container: Container) throws -> WelcomeController {
        let slack = try container.make(Slack.self)
        let controller = WelcomeController(slackClient: slack, logger: try container.make())
        slack.register(responder: controller, on: container)

        return controller
    }
}

extension WelcomeController: SlackResponder {

}
