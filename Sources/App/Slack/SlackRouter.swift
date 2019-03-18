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
    func registerCommand<C>(for eventTypes: [EventType], commandGenerator: CommandGenerator, use handler: @escaping (C, User) throws -> Void)
}

extension SlackRouter {
    public func register(collection: CommandCollection) throws {
        try collection.boot(router: self)
    }
}

protocol CommandCollection {
    func boot(router: SlackRouter) throws
}

// Currently we don't support any registration of more specific routes,
// everyone gets everything. In the future, a proper Route type should be developed
// to provide the router with enough information to decide who to actually deliver things to
public final class StandardSlackRouter: Service, SlackRouter {

    private var responders = [EventType: [SlackResponder]]()
    private var commandGenerators = [EventType: [CommandGenerator]]()

    func register(responder: SlackResponder, for eventTypes: [EventType]) {
        eventTypes.forEach {
            var respondersForType = responders[$0] ?? []
            respondersForType.append(responder)
            responders[$0] = respondersForType
        }
    }

    func registerCommand<C>(for eventTypes: [EventType], commandGenerator: CommandGenerator, use handler: @escaping (C, User) throws -> Void) {
        eventTypes.forEach {
            var generatorsForType = commandGenerators[$0] ?? []

            guard commandGenerator.register(handler: handler) else {
                return
            }

            generatorsForType.append(commandGenerator)
            commandGenerators[$0] = generatorsForType
        }
    }

    func handle(event: Event, ofType type: EventType, forBotUser botUser: User) throws {

        if type == .message, let message = SlackKitIncomingMessage(event: event) {
            try commandGenerators[.message]?.forEach { generator in
                try generator.handle(incomingMessage: message, botUser: botUser)
            }

            try responders[.message]?.forEach { try $0.handle(incomingMessage: message, forBotUser: botUser) }
            return
        }

        // Fallback to the generic event handler
        try responders[type]?.forEach { try $0.handle(event: event, ofType: type, forBotUser: botUser) }
    }
}
