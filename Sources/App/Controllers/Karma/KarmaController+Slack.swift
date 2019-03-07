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

                let attachments = karma.map { KarmaMessage(user: $0.id ?? "", karma: $0.count).karmaAttachment() }
                return try req.client().post(responseUrl) { beforePost in
                    let karmaResponse = KarmaResponse(attachments: attachments)
                    try beforePost.content.encode(json: karmaResponse)
                }
            }
            .catch {
                self.log.error("Failed to respond to Slack slash command \($0)")
        }
    }
}

extension KarmaController: SlackResponder {

    func handle(message: Message) throws {
        guard let sendingUser = message.sender else { return }

        let karmaMessages = karmaParser.karmaMessages(from: message.text)

        try karmaMessages.forEach { karmaMessage in
            let slack = self.slack
            let statusRepository = self.karmaStatusRepository
            let log = self.log

            guard karmaMessage.user != sendingUser else {
                let errorMessage = "You can't adjust karma for yourself! "
                try slack.send(message: message.response(with: errorMessage), onlyVisibleTo: sendingUser)
                return
            }

            // Update karma
            statusRepository.find(id: karmaMessage.user)
                .unwrap(or: Abort(.notFound))
                .flatMap { storedKarma in
                    storedKarma.count += karmaMessage.karma
                    return statusRepository.save(karma: storedKarma)
                }.catchFlatMap { _ in
                    statusRepository.save(karma: karmaMessage.statusData())
                }.thenThrowing { karma -> Void in
                    let response = message.response(with: karmaMessage.slackUser(),
                                                    attachments: [karmaMessage.slackAttachment(with: karma.count)])
                    try slack.send(message: response)
                }.catchMap { error in
                    let errorMessage = "Something went wrong. Please try again"
                    try slack.send(message: message.response(with: errorMessage), onlyVisibleTo: sendingUser)
                }.catch {
                    log.error("Completely unhandled Karma error occurred. This is bad, so bad: \($0)")
            }
        }
    }
}
