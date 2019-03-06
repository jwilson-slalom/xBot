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

/// Represents a message from Slack. We could very easily create different types for
/// incoming and outgoing messages to avoid having optional properties
class Message {
    let text: String
    let channelID: ChannelID
    let parent: String?

    // I don't know that it makes sense to receive these?
    var attachments = [Attachment]()

    // Sender is only really useful for messages we've received
    var sender: String? = nil
    var timestamp: String? = nil

    init(text: String, channelID: ChannelID, parent: String? = nil) {
        self.text = text
        self.channelID = channelID
        self.parent = parent
    }

    public convenience init?(event: Event) {
        guard let messageText = event.message?.text else { return nil }
        guard let channelID = event.channel?.id else { return nil }

        self.init(text: messageText, channelID: .init(id: channelID), parent: event.message?.threadTs)

        sender = event.user?.id
        timestamp = event.message?.ts
    }

    /// Constructs a new message in response to this one. If this message is in a thread,
    /// the response will be in the same thread. If it is not, then the response won't be
    func response(with text: String? = nil, attachments: [Attachment]? = nil) -> Message {
        let response = Message(text: text ?? "", channelID: channelID, parent: parent)
        attachments.map { response.attachments = $0 }
        return response
    }

    /// Constructs a new message in response to this one. The response will be threaded on the original
    func threadedResponse(with text: String? = nil, attachments: [Attachment]? = nil) -> Message {
        let response = Message(text: text ?? "", channelID: channelID, parent: timestamp)
        attachments.map { response.attachments = $0 }
        return response
    }
}
