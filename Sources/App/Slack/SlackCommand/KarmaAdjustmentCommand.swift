//
//  KarmaAdjustmentCommand.swift
//  App
//
//  Created by Jacob Wilson on 3/18/19.
//

import SlackKit

struct KarmaAdjustmentCommand: SlackCommand {
    let incomingMessage: SlackKitIncomingMessage
    let adjustments: [KarmaAdjustment]
}

class KarmaAdjustmentResponder: SlackCommandResponder {
    private var completion: ((KarmaAdjustmentCommand, User) throws -> Void)?
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

        try completion?(command, botUser)
    }

    func register<C>(completion: @escaping (C, User) throws -> Void) -> Bool {
        guard let completion = completion as? (KarmaAdjustmentCommand, User) throws -> Void else {
            return false
        }
        self.completion = completion
        return true
    }
}
