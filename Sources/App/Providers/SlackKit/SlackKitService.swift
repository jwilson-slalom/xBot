//
//  SlackKitService.swift
//  App
//
//  Created by Jacob Wilson on 2/21/19.
//

import Vapor
import SlackKit

protocol SlackHandler {
    func handleEvent(event: Event, slack: SlackMessageSender)
    var eventTypes: [EventType] { get }
}

final class SlackKitService {
    private let bot: SlackKit
    private let apiKeyStorage: APIKeyStorage
    private var handlers = [SlackHandler]()

    init(_ apiKeyStorage: APIKeyStorage,
         // We're capturing the container here, but a more flexible architure
         // would follow the routing patterns used by the the vapor HTTP service
         container: Container) throws {

        self.bot = SlackKit()
        self.apiKeyStorage = apiKeyStorage

        handlers.append(try container.make(OnTapController.self))
    }

    public func registerRTMConnection() {
        bot.addRTMBotWithAPIToken(apiKeyStorage.botUserApiKey, rtm: VaporEngineRTM())

        let eventTypes: [EventType] =
        [
            .message,
            .channelJoined
        ]

        for type in eventTypes {
            bot.notificationForEvent(type) { (event, connection) in
                guard let connection = connection else { return }

                self.handleEvent(event, onConnection: connection)
            }
        }
//        bot.notificationForEvent(.message) { event, clientConnection in
//            guard let connection = clientConnection else {
//                print("Bad ClientConnection")
//                return
//            }
//
//            guard let channelId = event.channel?.id, event.message?.botID == nil else {
//                print("Bad Channel Id")
//                return
//            }
//
//            let todo = Karma(id: "Chameleon")
//
//            let todoRequest = self.todoRepository.save(karma: todo)
//            todoRequest.addAwaiter { request in
//                guard let _ = request.result, request.error == nil else {
//                    print("Could not handle todo request")
//                    return
//                }
//
//                do {
//                    try self.sendMessage(using: connection, text: "Created Todo", channelId: channelId)
//                } catch {
//                    print("Error Sending Message: \(error)")
//                }
//            }
//        }
    }

    private func handleEvent(_ event: Event, onConnection connection: ClientConnection) {
        guard let type = event.type else {
            print("Unhandled event type")
            return
        }
        handlers
            .filter { $0.eventTypes.contains(type) }
            .forEach { $0.handleEvent(event: event, slack: SlackMessageSender(clientConnection: connection)) }
    }
}

public struct SlackMessageSender {

    private let clientConnection: ClientConnection

    init(clientConnection: ClientConnection) {
        self.clientConnection = clientConnection
    }

    public func sendMessage(text: String, channelId: String) throws {
        guard let rtm = clientConnection.rtm else { throw Abort(.internalServerError) }

        try rtm.sendMessage(text, channelID: channelId)
    }
}

extension SlackKitService: ServiceType {

    static public func makeService(for container: Container) throws -> SlackKitService {
        let apiKeyStorage = try container.make(APIKeyStorage.self)

        return try .init(apiKeyStorage, container: container)
    }
}
