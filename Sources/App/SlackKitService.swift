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
    var bot: SlackKit

    init() {
        bot = SlackKit()
    }

    public func registerRTMConnection(with container: Container) {
        bot.addWebAPIAccessWithToken("xoxp-548586128101-547645124752-557599275843-7f43af1b0a56c236382e22e3f478ca0b")
        bot.addRTMBotWithAPIToken("xoxb-548586128101-557599279299-ZLx0RxuUKQw6vbkPtVsXN0WQ")

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
        return .init()
    }
}

public final class SlackKitProvider: Provider {
    public func register(_ services: inout Services) throws {
        services.register(SlackKitService.self)
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        let slackKitService = try container.make(SlackKitService.self)
        slackKitService.registerRTMConnection(with: container)

        return .done(on: container)
    }
}
