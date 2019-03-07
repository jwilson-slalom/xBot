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

    func karmaCommand(_ req: Request, content: Command) throws -> Future<Response> {
        guard let responseUrl = content.response_url else {
            return req.future(error: Abort(.badRequest))
        }

        // Do this in the background
        processKarmaCommand(req, content: content, responseUrl: responseUrl)

        // Respond immediately
        return req.response().encode(status: .ok, for: req)
    }

    private func processKarmaCommand(_ req: Request, content: Command, responseUrl: String) {
        let userIds = karmaParser.userIds(from: content.text ?? "")

        karmaStatusRepository.find(ids: userIds)
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
            }
            .catch {
                self.log.error("Failed to respond to Slack slash command \($0)")
        }
    }
}

extension KarmaController: SlackResponder {

    func handle(incomingMessage: SlackKitIncomingMessage) throws {

        let karmaChanges = karmaParser.receivedKarma(from: incomingMessage.text)

        try karmaChanges.forEach { change in
            let slack = self.slack
            let statusRepository = self.karmaStatusRepository
            let historyRepository = self.karmaHistoryRepository
            let log = self.log

            guard change.user != incomingMessage.sender else {
                let errorMessage = "You can't adjust karma for yourself! "
                try slack.send(message: SlackKitResponse(inResponseTo: incomingMessage, text: errorMessage), onlyVisibleTo: incomingMessage.sender)
                return
            }

            // Save history record
            let karmaHistory = KarmaSlackHistory(karmaCount: change.count, fromUser: incomingMessage.sender, karmaReceiver: change.user, channel: incomingMessage.channelID.id)
            historyRepository.save(history: karmaHistory)
                .catch {
                    log.error("Could not save history \($0)")
                }

            // Update karma
            statusRepository.find(id: change.user)
                .unwrap(or: Abort(.notFound))
                .flatMap { storedKarma in
                    storedKarma.count += change.count
                    return statusRepository.save(karma: storedKarma)
                }.catchFlatMap { _ in
                    statusRepository.save(karma: change.karmaData())
                }.thenThrowing { updatedKarma -> Void in
                    let response = KarmaStatusResponse(karmaGivingMessage: incomingMessage, receivedKarma: change, karmaStatus: updatedKarma)
                    try slack.send(message: response)
                }.catchMap { error in
                    let errorMessage = "Something went wrong. Please try again"
                    try slack.send(message: SlackKitResponse(inResponseTo: incomingMessage, text: errorMessage), onlyVisibleTo: incomingMessage.sender)
                }.catch {
                    log.error("Completely unhandled Karma error occurred. This is bad, so bad: \($0)")
                }
        }
    }
}

extension String {

    func slackMention() -> String {
        if self.hasPrefix("<@") {
            return self
        }

        return "<@\(self)>"
    }
}
