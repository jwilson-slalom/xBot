//
//  SlackKitService.swift
//  App
//
//  Created by Jacob Wilson on 2/21/19.
//

import Vapor
import SlackKit
import Starscream

class SlackKitService: Service {
    var bot: SlackKit

    init() {
        bot = SlackKit()

        registerRTMConnection()
    }

    private func registerRTMConnection() {
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
