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

final class SlackKitService: SlackMessageSender {

    private let bot: SlackKit
    private let apiKeyStorage: APIKeyStorage
    public var handlers = [SlackHandler]()

    init(_ apiKeyStorage: APIKeyStorage,
         // We're capturing the container here, but a more flexible architure
         // would follow the routing patterns used by the the vapor HTTP service
         container: Container) throws {

        self.bot = SlackKit()
        self.apiKeyStorage = apiKeyStorage
    }

    public func registerRTMConnection() {
        bot.addRTMBotWithAPIToken(apiKeyStorage.botUserApiKey, rtm: VaporEngineRTM())
        bot.addWebAPIAccessWithToken(apiKeyStorage.botUserApiKey)

        let eventTypes: [EventType] =
        [
            .message,
            .channelJoined
        ]

        for type in eventTypes {
            bot.notificationForEvent(type) { (event, connection) in
                guard let connection = connection else { return }
                guard event.message?.botID == nil else { return }

                self.handleEvent(event, onConnection: connection)
            }
        }
    }

    func sendMessage(text: String, channelId: String, attachments: [Attachment]?) throws {
        guard let connection = self.bot.clients.first?.value else {
            print("No connection")
            return
        }
        try SlackResponseMessageSender(clientConnection: connection).sendMessage(text: text, channelId: channelId, attachments: attachments)
    }

    func sendErrorMessage(text: String, channelId: String, user: String) throws {
        guard let connection = self.bot.clients.first?.value else {
            print("No connection")
            return
        }
        try SlackResponseMessageSender(clientConnection: connection).sendErrorMessage(text: text, channelId: channelId, user: user)
    }

    private func handleEvent(_ event: Event, onConnection connection: ClientConnection) {
        guard let type = event.type else {
            print("Unhandled event type")
            return
        }
        handlers
            .filter { $0.eventTypes.contains(type) }
            .forEach { $0.handleEvent(event: event, slack: SlackResponseMessageSender(clientConnection: connection)) }
    }
}

class GenericMessageSender: SlackMessageSender {
    typealias SlackMessage = (String, String, [Attachment]?) throws -> Void
    typealias SlackErrorMessage = (String, String, String) throws -> Void

    private let messageFunction: SlackMessage
    private let errorMessageFunction: SlackErrorMessage

    init(_ message: @escaping SlackMessage, error: @escaping SlackErrorMessage) {
        self.messageFunction = message
        self.errorMessageFunction = error
    }

    public func sendMessage(text: String, channelId: String, attachments: [Attachment]? = nil) throws {
        try messageFunction(text, channelId, attachments)
    }

    func sendErrorMessage(text: String, channelId: String, user: String) throws {
        try errorMessageFunction(text, channelId, user)
    }
}

protocol SlackMessageSender {
    func sendMessage(text: String, channelId: String, attachments: [Attachment]?) throws
    func sendErrorMessage(text: String, channelId: String, user: String) throws
}

public struct SlackResponseMessageSender: SlackMessageSender {

    private let clientConnection: ClientConnection

    init(clientConnection: ClientConnection) {
        self.clientConnection = clientConnection
    }

    func sendMessage(text: String, channelId: String, attachments: [Attachment]? = nil) throws {
        guard let web = clientConnection.webAPI else { throw Abort(.internalServerError) }

        web.sendMessage(channel: channelId, text: text, attachments: attachments, success: { (ts, channel) in

        }, failure: { Error in
            
        })
    }

    func sendErrorMessage(text: String, channelId: String, user: String) throws {
        guard let web = clientConnection.webAPI else { throw Abort(.internalServerError) }

        web.sendEphemeral(channel: channelId, text: text, user: user, success: { (ts, channel) in

        }, failure: { Error in

        })
    }
}

extension SlackKitService: ServiceType {

    static public func makeService(for container: Container) throws -> SlackKitService {
        let apiKeyStorage = try container.make(APIKeyStorage.self)

        return try .init(apiKeyStorage, container: container)
    }
}
