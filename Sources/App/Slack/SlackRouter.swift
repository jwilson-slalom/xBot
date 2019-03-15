//
//  SlackRouter.swift
//  App
//
//  Created by Allen Humphreys on 3/13/19.
//

import SlackKit
import Vapor

/// `shadow` protocol
protocol AnyCommandResponder {
    func respond(to command: Any, user: User) throws
}
/// `BotCommandGenerator` To be shadowed.
protocol BotCommandResponder: AnyCommandResponder {
    associatedtype Command

    func respond(to command: Command, user: User) throws
}
/// `extension` to conform to `TableRow`
extension AnyCommandResponder {
    func respond(to command: Any, user: User) throws {
        fatalError()
    }
}
struct BasicCommandResponder<Command>: BotCommandResponder {
    private let closure: (Command, User) throws -> Void

    public init(closure: @escaping (Command, User) throws -> Void) {
        self.closure = closure
    }

    func respond(to command: Command, user: User) throws {
        try closure(command, user)
    }
}

protocol SlackRouter: SlackResponder {
    func register(responder: SlackResponder, for eventTypes: [EventType])
    func registerHandler<C>(handler: @escaping (C, User) throws -> Void, for eventTypes: [EventType])
}

// Currently we don't support any registration of more specific routes,
// everyone gets everything. In the future, a proper Route type should be developed
// to provide the router with enough information to decide who to actually deliver things to
public final class StandardSlackRouter: Service, SlackRouter {

    private var responders = [EventType: [SlackResponder]]()
    private var commandResponders = [EventType: [AnyCommandResponder]]()
    private let commandGenerators: [AnyCommandGenerator] = [KarmaAdjustmentCommandGenerator(),
                                                            OtherCommandGenerator()]
    func register(responder: SlackResponder, for eventTypes: [EventType]) {
        eventTypes.forEach {
            var respondersForType = responders[$0] ?? []
            respondersForType.append(responder)
            responders[$0] = respondersForType
        }
    }

    func registerHandler<C>(handler: @escaping (C, User) throws -> Void, for eventTypes: [EventType]) {
        eventTypes.forEach {
            var commandRespondersForType = commandResponders[$0] ?? []
            let responder = BasicCommandResponder<C>(closure: handler)
            commandRespondersForType.append(responder)
            commandResponders[$0] = commandRespondersForType
        }
    }

    func handle(event: Event, ofType type: EventType, forBotUser botUser: User) throws {

        if type == .message, let message = SlackKitIncomingMessage(event: event) {

            try commandGenerators.forEach { generator in
                if let gen = generator as? KarmaAdjustmentCommandGenerator,
                    let command = gen.commandFrom(incomingMessage: message) {

                    try commandResponders[.message]?.forEach { res in
                        if let responder = res as? BasicCommandResponder<KarmaAdjustmentCommand> {
                            try responder.respond(to: command, user: botUser)
                        }
                        if let responder = res as? BasicCommandResponder<OtherCommand> {
                            try responder.respond(to: command, user: botUser)
                        }
                    }
                }
                if let gen = generator as? OtherCommandGenerator,
                    let command = gen.commandFrom(incomingMessage: message) {

                    try commandResponders[.message]?.forEach {
                        try $0.respond(to: command, user: botUser)
                    }
                }
            }

            try responders[.message]?.forEach { try $0.handle(incomingMessage: message, forBotUser: botUser) }
            return
        }

        // Fallback to the generic event handler
        try responders[type]?.forEach { try $0.handle(event: event, ofType: type, forBotUser: botUser) }
    }
}
