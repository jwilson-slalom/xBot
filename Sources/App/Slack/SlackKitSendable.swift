//
//  SlackKitSendable.swift
//  App
//
//  Created by Allen Humphreys on 3/7/19.
//

import SlackKit

protocol SlackKitSendable {
    var channelID: ChannelID { get }
    var parent: String? { get }
    var text: String { get }
    var attachments: [Attachment]? { get }
}
