//
//  SlackKitService.swift
//  App
//
//  Created by Jacob Wilson on 2/21/19.
//

import Vapor
import SlackKit

public final class SlackKitProvider: Provider {
    public func register(_ services: inout Services) throws {
        services.register(SlackKitService.self)
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        let service = try container.make(SlackKitService.self)
        service.registerRTMConnection()
        return .done(on: container)
    }
}

public final class SlackKitService {
    private let bot: SlackKit
    private let apiKeyStorage: APIKeyStorage
    private let todoRepository: TodoRepository
    private let container: Container

    private init(_ apiKeyStorage: APIKeyStorage,
         todoRepository: TodoRepository,
         container: Container) {
        self.bot = SlackKit()
        self.apiKeyStorage = apiKeyStorage
        self.todoRepository = todoRepository
        self.container = container
    }

    public func registerRTMConnection() {
        bot.addRTMBotWithAPIToken(apiKeyStorage.botUserApiKey)

        bot.notificationForEvent(.message) { event, clientConnection in
            guard let connection = clientConnection else {
                print("Bad ClientConnection")
                return
            }

            guard let channelId = event.channel?.id else {
                print("Bad Channel Id")
                return
            }

            let eventText = event.text ?? ""
            let senderId = event.user?.id ?? ""
            let messageText = "Echo: \(eventText) sent from <@\(senderId)>"

            do {
                try self.sendMessage(using: connection, text: messageText, channelId: channelId)
            } catch {
                print("Error Sending Message: \(error)")
            }
        }
    }

    private func sendMessage(using clientConnection: ClientConnection, text: String, channelId: String) throws {
        guard let rtm = clientConnection.rtm else { throw Abort(.internalServerError) }

        try rtm.sendMessage(text, channelID: channelId)
    }
}

extension SlackKitService: ServiceType {
    static public func makeService(for container: Container) throws -> SlackKitService {
        let apiKeyStorage = try container.make(APIKeyStorage.self)
        let todoRepository = try container.make(TodoRepository.self)

        return .init(apiKeyStorage, todoRepository: todoRepository, container: container)
    }
}
