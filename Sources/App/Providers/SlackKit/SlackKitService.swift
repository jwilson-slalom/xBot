//
//  SlackKitService.swift
//  App
//
//  Created by Jacob Wilson on 2/21/19.
//

import Vapor
import SlackKit

final class SlackKitService {
    private let bot: SlackKit
    private let apiKeyStorage: APIKeyStorage
    private let todoRepository: KarmaRepository

    init(_ apiKeyStorage: APIKeyStorage,
         todoRepository: KarmaRepository) {

        self.bot = SlackKit()
        self.apiKeyStorage = apiKeyStorage
        self.todoRepository = todoRepository
    }

    public func registerRTMConnection() {
        bot.addRTMBotWithAPIToken(apiKeyStorage.botUserApiKey)

        bot.notificationForEvent(.message) { event, clientConnection in
            guard let connection = clientConnection else {
                print("Bad ClientConnection")
                return
            }

            guard let channelId = event.channel?.id, event.message?.botID == nil else {
                print("Bad Channel Id")
                return
            }

            let todo = Karma(id: "Chameleon")

            let todoRequest = self.todoRepository.save(karma: todo)
            todoRequest.addAwaiter { request in
                guard let _ = request.result, request.error == nil else {
                    print("Could not handle todo request")
                    return
                }

                do {
                    try self.sendMessage(using: connection, text: "Created Todo", channelId: channelId)
                } catch {
                    print("Error Sending Message: \(error)")
                }
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
        let todoRepository = try container.make(KarmaRepository.self)

        return .init(apiKeyStorage, todoRepository: todoRepository)
    }
}
