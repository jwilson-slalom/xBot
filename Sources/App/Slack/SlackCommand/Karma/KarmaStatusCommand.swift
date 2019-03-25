//
//  KarmaStatusCommand.swift
//  App
//
//  Created by Jacob Wilson on 3/18/19.
//

import SlackKit

struct KarmaStatusCommand: SlackCommand {
    let incomingMessage: SlackKitIncomingMessage
    let userIds: [String]
}

extension KarmaStatusCommand: Equatable { }

class KarmaStatusResponder: SlackCommandResponder {
    let commandInfo: CommandInfo = CommandInfo(usage: "@xbot status [@User @User ...]",
                                               description: "Displays current karma counts for a list of User's")

    private var completion: ((KarmaStatusCommand, User) throws -> Void)?
    private let karmaParser: KarmaParser

    init(karmaParser: KarmaParser = KarmaMessageParser()) {
        self.karmaParser = karmaParser
    }

    func handle(incomingMessage: SlackKitIncomingMessage, botUser: User) throws {
        guard let directedTo = karmaParser.karmaStatusMentionedUserId(from: incomingMessage.text) else { return }
        guard botUser.id == directedTo else { return }
        let userIds = karmaParser.userIds(from: incomingMessage.text)
        let excludingBotId = userIds.filter { return $0 != directedTo }

        guard !excludingBotId.isEmpty else {
            return
        }

        let command = KarmaStatusCommand(incomingMessage: incomingMessage, userIds: excludingBotId)

        try completion?(command, botUser)
    }

    func register<C>(completion: @escaping (C, User) throws -> Void) -> Bool {
        guard let completion = completion as? (KarmaStatusCommand, User) throws -> Void else {
            return false
        }
        self.completion = completion
        return true
    }
}
