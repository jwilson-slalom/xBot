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
}

class SlackKitResponse: SlackKitMessage {

    /// Constructs a new message in response to this one. If this message is in a thread,
    /// the response will be in the same thread. If it is not, then the response won't be
    init(inResponseTo incomingMessage: SlackKitIncomingMessage?, text: String? = nil, attachments: [Attachment]? = nil) {
        super.init(text: text ?? "", channelID: incomingMessage?.channelID ?? ChannelID(id: ""), parent: incomingMessage?.parent)
        attachments.map { self.attachments = $0 }
    }

    /// Constructs a new message in response to this one. The response will be threaded on the original
//    convenience init(threadResponseTo message: SlackKitIncomingMessage, with text: String? = nil, attachments: [Attachment]? = nil) {
//        if parent != nil {
//            self.init(responseTo: message, with: text, attachments: attachments)
//        } else {
//            super.init(text: text ?? "", channelID: channelID, parent: message.timestamp)
//        }
//    }
}
