//
//  Slack.swift
//  App
//
//  Created by Allen Humphreys on 3/2/19.
//

import SlackKit
import Vapor

protocol SlackMessageSender {
    func send(message: SlackKitSendable) throws
    func send(message: SlackKitSendable, onlyVisibleTo user: String) throws
}

struct Slack: SlackMessageSender {
    private let slackKit = SlackKit()
    private let log: Logger

    init(secrets: Secrets, logger: Logger) {
        self.log = logger
        slackKit.addWebAPIAccessWithToken(secrets.slackAppBotUserAPI)
    }

    func send(message: SlackKitSendable) throws {
        guard let web = slackKit.webAPI else { throw Abort(.internalServerError) }

        if let parentMessage = message.parent {
            web.sendThreadedMessage(
                channel: message.channelID.id,
                thread: parentMessage,
                text: message.text,
                attachments: message.attachments,
                success: { (ts, channel) in

                },
                failure: { error in
                    self.log.error("Sending slack message encounted error: \(error)")
                })
        } else {
            web.sendMessage(
                channel: message.channelID.id,
                text: message.text,
                attachments: message.attachments,
                success: { (ts, channel) in

                },
                failure: { error in
                    self.log.error("Sending slack message encounted error: \(error)")
                }
            )
        }
    }

    func send(message: SlackKitSendable, onlyVisibleTo user: String) throws {
        guard let web = slackKit.webAPI else { throw Abort(.internalServerError) }

        if let _ = message.parent {
            // Not yet supported by SlackKit (should be supported as far as I can tell)
        } else {
            web.sendEphemeral(channel: message.channelID.id, text: message.text, user: user, success: { (ts, channel) in

            }, failure: { error in
                self.log.error("Sending ephemeral slack message encounted error: \(error)")
            })
        }
    }
}

extension Slack: ServiceType {
    static let serviceSupports: [Any.Type] = [SlackMessageSender.self]

    static func makeService(for container: Container) throws -> Slack {
        return Slack(secrets: try container.make(),
                     logger: try container.make())
    }
}
