//
//  KarmaHelpCommand.swift
//  App
//
//  Created by Jacob Wilson on 3/19/19.
//


import SlackKit

struct KarmaHelpCommand: SlackCommand {
    let incomingMessage: SlackKitIncomingMessage
    let helpMessage: String
}

extension KarmaHelpCommand: Equatable { }

class KarmaHelpResponder: SlackCommandResponder {
    let commandInfo: CommandInfo = CommandInfo(usage: "@xbot help",
                                               description: "Shows available comamnds and how to use them")
    
    private var completion: ((KarmaHelpCommand, User) throws -> Void)?

    private let isRelease: Bool
    private let karmaParser: KarmaParser

    init(isRelease: Bool, karmaParser: KarmaParser = KarmaMessageParser()) {
        self.isRelease = isRelease
        self.karmaParser = karmaParser
    }

    func handle(incomingMessage: SlackKitIncomingMessage, botUser: User) throws {
        guard let directedTo = karmaParser.helpMentionedUserId(from: incomingMessage.text) else { return }
        guard botUser.id == directedTo else { return }

        // TODO: There is definitely a better way to get/set the help link.
        let link = isRelease ? "https://slalom-build-xbot.herokuapp.com/help" : "http://localhost:8080/help"
        let helpMessage = "For more information about xBot and how to interact with me, visit this <\(link)|help site>"
        let command = KarmaHelpCommand(incomingMessage: incomingMessage, helpMessage: helpMessage)

        try completion?(command, botUser)
    }

    func register<C>(completion: @escaping (C, User) throws -> Void) -> Bool {
        guard let completion = completion as? (KarmaHelpCommand, User) throws -> Void else {
            return false
        }
        self.completion = completion
        return true
    }
}
