//
//  KarmaController+Slack.swift
//  App
//
//  Created by Jacob Wilson on 3/7/19.
//

import Vapor

extension KarmaController {
    func registerSlackRoutes(on router: Router) {
        router.post("command", use: command)
        router.post(Command.self, at: "command/karma", use: karmaCommand)
    }

    func command(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(Command.self).flatMap { _ in
            try Leaderboard(text: "leaderboard").encode(for: req)
        }
    }

    func karmaCommand(_ req: Request, content: Command) throws -> HTTPStatus {
        guard let responseUrl = content.response_url else {
            return .badRequest
        }
        guard try req.validateSlackRequest(signingSecret: secrets.slackRequestSigningSecret) else {
            return .unauthorized
        }

        // Do this in the background
        processKarmaCommand(req, content: content, responseUrl: responseUrl)

        // Respond immediately
        return .ok
    }

    private func processKarmaCommand(_ req: Request, content: Command, responseUrl: String) {
        let userIds = karmaParser.userIds(from: content.text ?? "")

        karmaStatusRepository
            .find(ids: userIds)
            .flatMap { karma -> Future<Response> in
                guard !karma.isEmpty else {
                    return try req.client().post(responseUrl) { beforePost in
                        let message = SimpleMessage(text: "Couldn't find any karma!")
                        try beforePost.content.encode(json: message)
                    }
                }

                return try req.client().post(responseUrl) { beforePost in
                    let karmaResponse = KarmaStatusResponse(forSlashCommandWithKarmaStatuses: karma)
                    try beforePost.content.encode(json: karmaResponse)
                }
            }.catch {
                self.log.error("Failed to respond to Slack slash command \($0)")
            }
    }
}

extension KarmaController: SlackResponder {

    func handle(incomingMessage: SlackKitIncomingMessage) throws {

        let karmaChanges = karmaParser.karmaAdjustments(from: incomingMessage.text)

        let slack = self.slack
        let statusRepository = self.karmaStatusRepository
        let historyRepository = self.karmaHistoryRepository
        let log = self.log

        try karmaChanges.forEach { change in

            guard change.user != incomingMessage.sender else {
                let errorMessage = "You can't adjust karma for yourself! "
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
