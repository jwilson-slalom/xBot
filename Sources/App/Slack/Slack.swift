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

    static func makeService(for container: Container) throws -> Slack {
        return Slack(apiKey: try container.make(APIKeyStorage.self),
                     listener: try container.make(SlackListener.self))
    }

    init(apiKey: APIKeyStorage, listener: SlackListener) {
        self.listener = listener
        slackKit.addWebAPIAccessWithToken(apiKey.botUserApiKey)
    }

    func register(responder: SlackResponder, on worker: Worker) {
        listener.register(responder: responder, on: worker)
    }

    func sendMessage(text: String, channelId: String, attachments: [Attachment]?) throws {
        guard let web = slackKit.webAPI else { throw Abort(.internalServerError) }

        web.sendMessage(
            channel: channelId,
            text: text,
            attachments: attachments,
            success: { (ts, channel) in

            },
            failure: { error in

            }
        )
    }

    func sendErrorMessage(text: String, channelId: String, user: String) throws {
        guard let web = slackKit.webAPI else { throw Abort(.internalServerError) }

        web.sendEphemeral(channel: channelId, text: text, user: user, success: { (ts, channel) in

        }, failure: { Error in

        })
    }
}
