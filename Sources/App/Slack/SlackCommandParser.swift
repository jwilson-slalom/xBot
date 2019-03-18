//
//  SlackCommandParser.swift
//  App
//
//  Created by Jacob Wilson on 3/14/19.
//

import SlackKit

protocol BotCommand {
    var incomingMessage: SlackKitIncomingMessage { get }
}

protocol CommandGenerator {
    func handle(incomingMessage: SlackKitIncomingMessage, botUser: User) throws
    func register<C>(handler: @escaping (C, User) throws -> Void) -> Bool
}

class KarmaAdjustmentCommandGenerator: CommandGenerator {
    private var handler: ((KarmaAdjustmentCommand, User) throws -> Void)?
    private let karmaParser: KarmaParser

    init() {
        karmaParser = KarmaMessageParser()
    }

    func handle(incomingMessage: SlackKitIncomingMessage, botUser: User) throws {
        let karmaAdjustments = karmaParser.karmaAdjustments(from: incomingMessage.text)

        guard !karmaAdjustments.isEmpty else {
            return
        }

        let command = KarmaAdjustmentCommand(incomingMessage: incomingMessage, adjustments: karmaAdjustments)

        try handler?(command, botUser)
    }

    func register<C>(handler: @escaping (C, User) throws -> Void) -> Bool {
        guard let handler = handler as? (KarmaAdjustmentCommand, User) throws -> Void else {
            return false
        }
        self.handler = handler
        return true
    }
}

class OtherCommandGenerator: CommandGenerator {
    private var handler: ((OtherCommand, User) throws -> Void)?

    func handle(incomingMessage: SlackKitIncomingMessage, botUser: User) throws {
        guard incomingMessage.text == "other" else {
            return
        }

        let command = OtherCommand(incomingMessage: incomingMessage)

        try handler?(command, botUser)
    }

    func register<C>(handler: @escaping (C, User) throws -> Void) -> Bool {
        guard let handler = handler as? (OtherCommand, User) throws -> Void else {
            return false
        }
        self.handler = handler
        return true
    }
}

struct KarmaAdjustmentCommand: BotCommand {
    let incomingMessage: SlackKitIncomingMessage
    let adjustments: [KarmaAdjustment]
}

struct OtherCommand: BotCommand {
    let incomingMessage: SlackKitIncomingMessage
}

//enum BotCommandType {
//    case karmaAdjustments
//    case currentKarmaStatus
//    case karmaLeaderboard
//    case currentBeers
//}
