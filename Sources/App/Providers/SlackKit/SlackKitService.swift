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
    private let todoController: TodoController
    private let container: Container

    init(_ apiKeyStorage: APIKeyStorage,
         todoController: TodoController,
         container: Container) {

        self.bot = SlackKit()
        self.apiKeyStorage = apiKeyStorage
        self.todoController = todoController
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

            let todo = Todo(title: "Created from Slack")

            do {
                let todoRequest = try todo.encode(using: self.container).flatMap { request in
                    return try self.todoController.create(request)
                }

                todoRequest.addAwaiter { request in
                    guard let todo = request.result, request.error == nil else {
                        print("Could not handle todorequest")
                        return
                    }

                    do {
                        try self.sendMessage(using: connection, text: "Created Todo with title \(todo.title)", channelId: channelId)
                    } catch {
                        print("Error Sending Message: \(error)")
                    }
                }
            } catch {
                print("Error handling todo request: \(error)")
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
        let todoController = try container.make(TodoController.self)

        return .init(apiKeyStorage, todoController: todoController, container: container)
    }
}
