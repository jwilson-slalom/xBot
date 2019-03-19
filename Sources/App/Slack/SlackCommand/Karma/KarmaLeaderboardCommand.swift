//
//  KarmaLeaderboardCommand.swift
//  App
//
//  Created by Jacob Wilson on 3/19/19.
//

import SlackKit

struct KarmaLeaderboardCommand: SlackCommand {
    let incomingMessage: SlackKitIncomingMessage
    let leaderboardCount: Int

    init(incomingMessage: SlackKitIncomingMessage, leaderboardCount: Int = 10) {
        self.incomingMessage = incomingMessage
        self.leaderboardCount = leaderboardCount
    }
}

extension KarmaLeaderboardCommand: Equatable { }

class KarmaLeaderboardResponder: SlackCommandResponder {
    private var completion: ((KarmaLeaderboardCommand, User) throws -> Void)?
    private let karmaParser: KarmaParser

    init(karmaParser: KarmaParser = KarmaMessageParser()) {
        self.karmaParser = karmaParser
    }

    func handle(incomingMessage: SlackKitIncomingMessage, botUser: User) throws {
        guard let directedTo = karmaParser.leaderboardMentionedUserId(from: incomingMessage.text) else { return }
        guard botUser.id == directedTo else { return }

        let command = KarmaLeaderboardCommand(incomingMessage: incomingMessage)

        try completion?(command, botUser)
    }

    func register<C>(completion: @escaping (C, User) throws -> Void) -> Bool {
        guard let completion = completion as? (KarmaLeaderboardCommand, User) throws -> Void else {
            return false
        }
        self.completion = completion
        return true
    }
}
