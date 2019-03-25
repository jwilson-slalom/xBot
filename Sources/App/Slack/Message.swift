//
//  Message.swift
//  App
//
//  Created by Allen Humphreys on 3/5/19.
//

import SlackKit

// https://api.slack.com/messaging/managing
// https://api.slack.com/messaging/sending#threading
// https://api.slack.com/methods/chat.postMessage

class SimpleMessage: Encodable {
    let text: String
    var attachments: [Attachment]?

    init(text: String, attachments: [Attachment]? = nil) {
        self.text = text
        self.attachments = attachments
    }
}

/// Represents a message from Slack. We could very easily create different types for
/// incoming and outgoing messages to avoid having optional properties
class SlackKitMessage: SimpleMessage, SlackKitSendable {
    let channelID: ChannelID
    let parent: String?

    init(text: String, channelID: ChannelID, parent: String? = nil) {
        self.channelID = channelID
        self.parent = parent

        super.init(text: text)
    }
}

class SlackKitIncomingMessage: SlackKitMessage {
    let sender: String
    let timestamp: String

    public init?(event: Event) {
        guard let messageText = event.message?.text else { return nil }
        guard let channelID = event.channel?.id else { return nil }
        guard let sender = event.user?.id else { return nil }
        guard let timestamp = event.message?.ts else { return nil }

        self.sender = sender
        self.timestamp = timestamp

        super.init(text: messageText, channelID: .init(id: channelID), parent: event.message?.threadTs)
    }

    public init(messageText: String,
                channelId: String,
                sender: String,
                timestamp: String) {


        self.sender = sender
        self.timestamp = timestamp

        super.init(text: messageText, channelID: .init(id: channelId))
    }
}

extension SlackKitIncomingMessage: Equatable {
    static func == (lhs: SlackKitIncomingMessage, rhs: SlackKitIncomingMessage) -> Bool {
        return lhs.text == rhs.text &&
                lhs.parent == rhs.parent &&
                lhs.channelID == rhs.channelID &&
                lhs.sender == rhs.sender &&
                lhs.timestamp == rhs.timestamp
    }
}

class SlackKitResponse: SlackKitMessage {

    /// Constructs a new message in response to this one. If this message is in a thread,
    /// the response will be in the same thread. If it is not, then the response won't be
    init(to incomingMessage: SlackKitIncomingMessage?, text: String = "", attachments: [Attachment]? = nil) {
        super.init(text: text, channelID: incomingMessage?.channelID ?? ChannelID(id: ""), parent: incomingMessage?.parent)
        attachments.map { self.attachments = $0 }
    }

    /// Constructs a new message in response to an incoming message. The response will be threaded on the incoming message
    /// or simply a response to the incoming message if it was already threaded.
    ///
    /// You only need to call this if you plan to start a new thread
    init(threadedOn incomingMessage: SlackKitIncomingMessage, text: String = "", attachments: [Attachment]? = nil) {
        if incomingMessage.parent != nil {
            super.init(text: text, channelID: incomingMessage.channelID, parent: incomingMessage.parent)
        } else {
            super.init(text: text, channelID: incomingMessage.channelID, parent: incomingMessage.timestamp)
        }
    }
}

extension SlackKitResponse: Equatable {
    static func == (lhs: SlackKitResponse, rhs: SlackKitResponse) -> Bool {
        return lhs.text == rhs.text &&
                lhs.parent == rhs.parent &&
                lhs.channelID == rhs.channelID// &&
                //lhs.attachments == rhs.attachments
    }
}

class SlackHelpResponse: SlackKitResponse {
    init(from helpCommand: KarmaHelpCommand) {
        let attachment = SlackHelpResponse.helpAttachment(from: helpCommand)
        super.init(to: helpCommand.incomingMessage, text: "", attachments: [attachment])
    }

    static func helpAttachment(from helpCommand: KarmaHelpCommand) -> Attachment {
        return Attachment(attachment: [
            "fallback": "xBot Help",
            "title": "xBot Help",
            "mrkdwn_in": ["text"],
            "text": helpCommand.helpMessage
            ])
    }
}
