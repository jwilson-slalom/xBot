//
//  Slack.swift
//  App
//
//  Created by Allen Humphreys on 3/2/19.
//

import SlackKit
import Vapor

struct Slack: ServiceType {
    private let slackKit = SlackKit()
    private let listener: SlackListener
    private let log: Logger

    public var botUser: User? {
        return listener.botUser
    }

    static func makeService(for container: Container) throws -> Slack {
        return Slack(apiKey: try container.make(APIKeyStorage.self),
                     listener: try container.make(SlackListener.self),
                     logger: try container.make(Logger.self))
    }

    init(apiKey: APIKeyStorage, listener: SlackListener, logger: Logger) {
        self.listener = listener
        self.log = logger
        slackKit.addWebAPIAccessWithToken(apiKey.botUserApiKey)
    }

    func register(responder: SlackResponder, on worker: Worker) {
        listener.register(responder: responder, on: worker)
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

    func send(message: SlackKitMessage, onlyVisibleTo user: String) throws {
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
