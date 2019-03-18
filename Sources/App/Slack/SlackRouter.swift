//
//  SlackRouter.swift
//  App
//
//  Created by Allen Humphreys on 3/13/19.
//

import SlackKit
import Vapor

protocol CommandCollection {
    func boot(router: SlackRouter) throws
}

protocol SlackRouter: SlackResponder {
    func register(responder: SlackResponder, for eventTypes: [EventType])
    func registerCommandResponder<C>(for eventTypes: [EventType], responder: SlackCommandResponder, use completion: @escaping (C, User) throws -> Void)
}

extension SlackRouter {
    public func register(collection: CommandCollection) throws {
        try collection.boot(router: self)
    }
}

// Currently we don't support any registration of more specific routes,
// everyone gets everything. In the future, a proper Route type should be developed
// to provide the router with enough information to decide who to actually deliver things to
public final class StandardSlackRouter: Service, SlackRouter {

    private var responders = [EventType: [SlackResponder]]()
    private var commandResponders = [EventType: [SlackCommandResponder]]()

    func register(responder: SlackResponder, for eventTypes: [EventType]) {
        eventTypes.forEach {
            var respondersForType = responders[$0] ?? []
            respondersForType.append(responder)
            responders[$0] = respondersForType
        }
    }

    func registerCommandResponder<C>(for eventTypes: [EventType], responder: SlackCommandResponder, use completion: @escaping (C, User) throws -> Void) {
        eventTypes.forEach {
            var respondersForType = commandResponders[$0] ?? []

            guard responder.register(completion: completion) else {
                return
            }

            respondersForType.append(responder)
            commandResponders[$0] = respondersForType
        }
    }

    func handle(event: Event, ofType type: EventType, forBotUser botUser: User) throws {

        if type == .message, let message = SlackKitIncomingMessage(event: event) {
            try commandResponders[.message]?.forEach { try $0.handle(incomingMessage: message, botUser: botUser) }

            try responders[.message]?.forEach { try $0.handle(incomingMessage: message, forBotUser: botUser) }
            return
        }

        // Fallback to the generic event handler
        try responders[type]?.forEach { try $0.handle(event: event, ofType: type, forBotUser: botUser) }
    }
}
