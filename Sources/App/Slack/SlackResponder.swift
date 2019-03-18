//
//  SlackResponder.swift
//  App
//
//  Created by Allen Humphreys on 3/2/19.
//

import SlackKit

protocol SlackResponder {
    func handle(incomingMessage: SlackKitIncomingMessage, forBotUser botUser: User) throws
    func handle(event: Event, ofType type: EventType, forBotUser botUser: User) throws
}

extension SlackResponder {
    func handle(incomingMessage: SlackKitIncomingMessage, forBotUser botUser: User) throws { }
    func handle(event: Event, ofType type: EventType, forBotUser botUser: User) throws { }
}
