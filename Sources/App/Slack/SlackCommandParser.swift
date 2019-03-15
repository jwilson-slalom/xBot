//
//  SlackCommandParser.swift
//  App
//
//  Created by Jacob Wilson on 3/14/19.
//

protocol BotCommand {
    var type: BotCommandType { get }
    var incomingMessage: SlackKitIncomingMessage { get }
}

/// `shadow` protocol
protocol AnyCommandGenerator {
    func commandFrom(incomingMessage: SlackKitIncomingMessage) -> Any?
}
/// `BotCommandGenerator` To be shadowed.
protocol BotCommandGenerator: AnyCommandGenerator {
    associatedtype Command

    func commandFrom(incomingMessage: SlackKitIncomingMessage) -> Command?
}
/// `extension` to conform to `TableRow`
extension AnyCommandGenerator {
    func commandFrom(incomingMessage: SlackKitIncomingMessage) -> Any? {
        return nil
    }
}

struct KarmaAdjustmentCommandGenerator: BotCommandGenerator {
    typealias Command = KarmaAdjustmentCommand

    let karmaParser: KarmaParser

    init() {
        karmaParser = KarmaMessageParser()
    }

    func commandFrom(incomingMessage: SlackKitIncomingMessage) -> KarmaAdjustmentCommand? {
        let karmaAdjustments = karmaParser.karmaAdjustments(from: incomingMessage.text)

        guard !karmaAdjustments.isEmpty else {
            return nil
        }

        return KarmaAdjustmentCommand(incomingMessage: incomingMessage, adjustments: karmaAdjustments)
    }
}

struct OtherCommandGenerator: BotCommandGenerator {
    typealias Command = OtherCommand

    func commandFrom(incomingMessage: SlackKitIncomingMessage) -> OtherCommand? {
        guard incomingMessage.text == "other" else {
            return nil
        }

        return OtherCommand(incomingMessage: incomingMessage)
    }
}

struct KarmaAdjustmentCommand: BotCommand {
    let type: BotCommandType = .karmaAdjustments
    let incomingMessage: SlackKitIncomingMessage
    let adjustments: [KarmaAdjustment]
}

struct OtherCommand: BotCommand {
    let type: BotCommandType = .currentKarmaStatus
    let incomingMessage: SlackKitIncomingMessage
}

enum BotCommandType {
    case karmaAdjustments
    case currentKarmaStatus
    case karmaLeaderboard
    case currentBeers
}
