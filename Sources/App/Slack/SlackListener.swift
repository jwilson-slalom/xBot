//
//  SlackListener.swift
//  App
//
//  Created by Allen Humphreys on 3/2/19.
//

import SlackKit
import Vapor

class SlackListenerProvider: Provider {

    func register(_ services: inout Services) throws {

        services.register(SlackListener.self)

        services.register(SlackRouter.self) { container -> StandardSlackRouter in
            let router = StandardSlackRouter()
            try slackRoutes(router, container)
            return router
        }
    }

    func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        _ = try container.make(SlackListener.self)
        return container.future()
    }
}

final class SlackListener {

    private let slackKit = SlackKit()

    public let secrets: Secrets
    private let router: SlackRouter
    private let log: Logger
    private let worker: Worker

    private var botUser: User? {
        return slackKit.clients[secrets.slackAppBotUserAPI]?.client?.authenticatedUser
    }

    private init(secrets: Secrets, router: SlackRouter, logger: Logger, on worker: Worker) {
        self.secrets = secrets
        self.router = router
        self.log = logger
        self.worker = worker

        slackKit.addRTMBotWithAPIToken(secrets.slackAppBotUserAPI, client: SimpleClient(), rtm: VaporEngineRTM())

        // Types not in this list are ignored entirely
        let eventTypes: [EventType] = [.message,
                                       .memberJoinedChannel,
                                       .teamJoin]

        for type in eventTypes {
            slackKit.notificationForEvent(type) { (event, connection) in
                guard let connection = connection else { return }
                guard event.message?.botID == nil else { return }

                self.handleEvent(event, onConnection: connection)
            }
        }
    }

    private func handleEvent(_ event: Event, onConnection connection: ClientConnection) {
        guard let type = event.type else {
            self.log.error("Event without a type came in")
            return
        }

        guard let botUser = botUser else {
            self.log.error("No bot user, can't be connected/listening, this is weird")
            return
        }

        let router = self.router

        // Jump to our event loop, this ensures synchronization on the responders for
        // this container
        worker
            .eventLoop
            .submit {
                try router.handle(event: event, ofType: type, forBotUser: botUser)
            }.catch { error in
                self.log.error("Slack responder threw an error: \(error)")
            }
    }
}

extension SlackListener: ServiceType {

    static func makeService(for container: Container) throws -> SlackListener {
        return SlackListener(secrets: try container.make(),
                             router: try container.make(),
                             logger: try container.make(),
                             on: container)
    }
}

extension SlackListener {

    final class SimpleClient: SKClient.Client {

        override func notificationForEvent(_ event: Event, type: EventType) {
            // Nothing, disables super class
        }
    }
}
