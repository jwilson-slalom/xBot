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
    private let karmaRepository: KarmaRepository

    init(_ apiKeyStorage: APIKeyStorage,
         karmaRepository: KarmaRepository) {

        self.bot = SlackKit()
        self.apiKeyStorage = apiKeyStorage
        self.karmaRepository = karmaRepository
    }

    public func registerRTMConnection() {
        bot.addRTMBotWithAPIToken(apiKeyStorage.botUserApiKey, rtm: VaporEngineRTM())

        bot.notificationForEvent(.message) { event, clientConnection in
            guard let connection = clientConnection else {
                print("Bad ClientConnection")
                return
            }

            guard let channelId = event.channel?.id, event.message?.botID == nil else {
                print("Bad Channel Id")
                return
            }

            if let message = event.text {
                let karmaParser = KarmaParser()
                let captureGroups = karmaParser.captureGroupsFrom(message: message)

                var outgoingMessage = ""
                for group in captureGroups {
                    outgoingMessage.append("\(group) | ")
                }

                do {
                    guard !outgoingMessage.isEmpty else {
                        return
                    }
                    try self.sendMessage(using: connection, text: outgoingMessage, channelId: channelId)
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
        let karmaRepository = try container.make(KarmaRepository.self)

        return .init(apiKeyStorage, karmaRepository: karmaRepository)
    }
}
