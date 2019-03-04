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
        shared.apiKey = try container.make(APIKeyStorage.self)
        return shared
    }

    private var responders = [String: [(SlackResponder, Worker)]]()
    private let slackKit = SlackKit()

    public var apiKey: APIKeyStorage? {
        didSet {
            guard apiKey != oldValue else { return }

            if let apiKey = apiKey {
                slackKit.addRTMBotWithAPIToken(apiKey.botUserApiKey, rtm: VaporEngineRTM())
            } else if let oldKey = oldValue {
                slackKit.clients[oldKey.botUserApiKey]?.rtm?.disconnect()
            }
        }
    }

    private init() {
        // Types not in this list are ignored entirely
        let eventTypes: [EventType] = [.message,
                                       .channelJoined]

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

        var responders = self.responders[serviceName] ?? []
        responders.append((responder, eventLoop))

        self.responders[serviceName] = responders
    }

    private func handleEvent(_ event: Event, onConnection connection: ClientConnection) {
        guard let type = event.type else {
            print("Unhandled event type")
            return
        }

        // TODO: Rotate which ones are chosen, will probably need a more formal type
        responders
            .values
            .compactMap { $0.first }
            .filter { $0.0.eventTypes.contains(type) }
            .forEach { responder, worker in
                worker.eventLoop.execute {
                    responder.handleEvent(event: event)
                }
            }
    }
}
