//
//  SlackKitService.swift
//  App
//
//  Created by Jacob Wilson on 2/21/19.
//

import Vapor
import SlackKit
import Starscream

final class SlackKitService {

    let bot = SlackKit()
    let apiKeyStorage: APIKeyStorage

    init(apiKeyStorage: APIKeyStorage) {
        self.apiKeyStorage = apiKeyStorage
    }

    public func registerRTMConnection(with container: Container) {

        bot.addRTMBotWithAPIToken(apiKeyStorage.botUserAPIKey)

        bot.notificationForEvent(.message) { event, clientConnection in

            guard let channelId = event.channel?.id,
                    let connection = clientConnection,
                    let rtm = connection.rtm else {
                print("Something was null coming back ")
                return
            }

            let text = event.text ?? "Could not read message text"

            do {
                try rtm.sendMessage("Echo: \(text)", channelID: channelId)
            } catch {
                print("Error Sending Message: \(error)")
            }
        }
    }
}
extension SlackKitService: ServiceType {

    static func makeService(for container: Container) throws -> SlackKitService {
        let apiKeyStorage = try container.make(APIKeyStorage.self)

        return SlackKitService(apiKeyStorage: apiKeyStorage)
    }
}

public struct SlackKitProvider: Provider {

    public func register(_ services: inout Services) throws {
        services.register(SlackKitService.self)
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {

        let slackKitService = try container.make(SlackKitService.self)
        slackKitService.registerRTMConnection(with: container)

        return .done(on: container)
    }
}
