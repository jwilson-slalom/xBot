//
//  SlackRouter.swift
//  App
//
//  Created by Allen Humphreys on 3/13/19.
//

import SlackKit
import Vapor

protocol SlackRouter: SlackResponder {
    func register(responder: SlackResponder, for eventTypes: [EventType])
}

// Currently we don't support any registration of more specific routes,
// everyone gets everything. In the future, a proper Route type should be developed
// to provide the router with enough information to decide who to actually deliver things to
public final class StandardSlackRouter: Service, SlackRouter {
    private var responders = [EventType: [SlackResponder]]()

    func register(responder: SlackResponder, for eventTypes: [EventType]) {

        eventTypes.forEach {
            var respondersForType = responders[$0] ?? []
            respondersForType.append(responder)
            responders[$0] = respondersForType
        }
    }

    func handle(event: Event, ofType type: EventType, forBotUser botUser: User) throws {

        if type == .message, let message = SlackKitIncomingMessage(event: event) {

            try responders[.message]?.forEach { try $0.handle(incomingMessage: message, forBotUser: botUser) }
            return
        }

        // Fallback to the generic event handler
        try responders[type]?.forEach { try $0.handle(event: event, ofType: type, forBotUser: botUser) }
    }
}
