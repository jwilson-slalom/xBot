//
//  KarmaController+Slack.swift
//  App
//
//  Created by Jacob Wilson on 3/7/19.
//

import Vapor
import struct SlackKit.User

extension KarmaController {
    func registerSlackRoutes(on router: Router) {
        router.post(Command.self, at: "command", use: command)
    }

    func command(_ req: Request, content: Command) throws -> HTTPStatus {
        guard let responseUrl = content.response_url else {
            return .badRequest
        }
        guard try req.validateSlackRequest(signingSecret: secrets.slackRequestSigningSecret) else {
            return .unauthorized
        }

        // Do this in the background
        send(karmaStatuses: process(karmaCommand: content, on: req), to: responseUrl, with: req, command: content)

        // Respond immediately
        return .ok
    }

    private func process(karmaCommand command: Command, on req: Request) -> Future<[KarmaStatus]> {
        let repository = karmaStatusRepository

        switch command.command {
        case "/leaderboard"?:
            return repository.top(count: 10)
        case "/karma"?:
            let userIds = karmaParser.userIds(from: command.text ?? "")
            return repository.find(ids: userIds)
        default:
            return req.future(error: Abort(.badRequest))
        }
    }

    private func send(karmaStatuses: Future<[KarmaStatus]>, to responseUrl: String, with req: Request, command: Command) {
        karmaStatuses
            .flatMap { karma -> Future<Response> in
                guard !karma.isEmpty else {
                    return try req.client().post(responseUrl) { beforePost in
                        let message = SimpleMessage(text: "Couldn't find any karma!")
                        try beforePost.content.encode(json: message)
                    }
                }

                return try req.client().post(responseUrl) { beforePost in
                    try beforePost.content.encode(json: self.formatter(for: command, karma: karma))
                }
            }.catch {
                self.log.error("Failed to respond to Slack slash command \($0)")
            }
    }

    private func formatter(for command: Command, karma: [KarmaStatus]) -> KarmaStatusResponse {
        switch command.command {
        case "/leaderboard"?:
            return  KarmaStatusResponse(forLeaderboardCommandStatuses: karma)
        default:
            return  KarmaStatusResponse(forSlashCommandWithKarmaStatuses: karma)
        }
    }
}

extension KarmaController: SlackResponder {

    func handle(incomingMessage: SlackKitIncomingMessage, forBotUser botUser: User) throws {

        let karmaChanges = karmaParser.karmaAdjustments(from: incomingMessage.text)

        let slack = self.slack
        let statusRepository = self.karmaStatusRepository
        let historyRepository = self.karmaHistoryRepository
        let log = self.log

        try karmaChanges.forEach { change in

            guard change.user != incomingMessage.sender else {
                let errorMessage = "You can't adjust karma for yourself!"
                try slack.send(message: SlackKitResponse(to: incomingMessage, text: errorMessage), onlyVisibleTo: incomingMessage.sender)
                return
            }

            // Save history record
            let karmaHistory = KarmaSlackHistory(karmaCount: change.count, karmaReceiver: change.user, karmaSender: incomingMessage.sender, inChannel: incomingMessage.channelID.id)
            historyRepository
                .save(history: karmaHistory)
                .catch {
                    log.error("Could not save history \($0)")
                }

            // Update karma
            statusRepository
                .find(id: change.user)
                .flatMap {
                    statusRepository.save(karma: KarmaStatus(id: change.user, count: ($0?.count ?? 0) + change.count))
                }.thenThrowing { updatedStatus -> Void in
                    try slack.send(message: KarmaStatusResponse(forKarmaAdjustingMessage: incomingMessage, receivedKarma: change, statusAfterChange: updatedStatus))
                }.catchMap { error in
                    let errorMessage = "Something went wrong. Please try again"
                    try slack.send(message: SlackKitResponse(to: incomingMessage, text: errorMessage), onlyVisibleTo: incomingMessage.sender)
                }.catch {
                    log.error("Completely unhandled Karma error occurred. This is bad, so bad: \($0)")
                }
        }
    }
}
