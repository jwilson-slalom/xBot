//
//  SlackListener.swift
//  App
//
//  Created by Allen Humphreys on 3/2/19.
//

import SlackKit
import Vapor

// Traditional singleton. Only a single listener is needed in the app
// because the websocket client is single threaded
final class SlackListener: ServiceType {

    private static var shared = SlackListener()
    static func makeService(for container: Container) throws -> SlackListener {
        shared.secrets = try container.make(Secrets.self)
        return shared
    }

    private let respondersLock = DispatchQueue(label: "responders.lock", qos: .default)
    private var responders = [String: [(SlackResponder, Worker)]]()

    private let slackKit = SlackKit()
    private let log = ConsoleLogger(console: Terminal())

    public var botUser: User? {
        return secrets.flatMap { slackKit.clients[$0.slackAppBotUserAPI] }?.client?.authenticatedUser
    }

    public var secrets: Secrets? {
        didSet {
            guard secrets != oldValue else { return }

            if let secrets = secrets {
                slackKit.addRTMBotWithAPIToken(secrets.slackAppBotUserAPI, client: SimpleClient(), rtm: VaporEngineRTM())
            } else if let oldKey = oldValue {
                slackKit.clients[oldKey.slackAppBotUserAPI]?.rtm?.disconnect()
            }
        }
    }

    private init() {
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

    func register(responder: SlackResponder, on eventLoop: Worker) {
        let serviceName = type(of: responder).serviceName

        respondersLock.sync {
            var responders = self.responders[serviceName] ?? []
            responders.append((responder, eventLoop))

            self.responders[serviceName] = responders
        }
    }

    private func handleEvent(_ event: Event, onConnection connection: ClientConnection) {
        guard let type = event.type else {
            self.log.error("Event without a type came in")
            return
        }

        // TODO: Rotate which ones are chosen, will probably need a more formal type

        let targets = responders.values.compactMap { $0.first }.filter { $0.0.eventTypes.contains(type) }

        if type == .message, let message = SlackKitIncomingMessage(event: event) {

            targets.forEach { responder, worker in
                worker.eventLoop.submit {
                    try responder.handle(incomingMessage: message)
                }.catch { error in
                    self.log.error("Slack responder threw an error: \(error)")
                }
            }
            return
        }

        // Fallback to the generic event handler
        targets.forEach { responder, worker in
            worker.eventLoop.submit {
                try responder.handle(event: event)
            }.catch { error in
                self.log.error("Slack responder threw an error: \(error)")
            }
        }
    }
}

extension SlackListener {

    final class SimpleClient: SKClient.Client {

        override func notificationForEvent(_ event: Event, type: EventType) {
            // Nothing, disables super class
        }
    }
}
