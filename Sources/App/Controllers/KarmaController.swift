import Vapor
import class SlackKit.Event
import enum SlackKit.EventType

/// Controls basic CRUD operations on `Karma`s.
final class KarmaController {

    private let karmaRepository: KarmaRepository
    private let karmaParser = KarmaParser()
    private let slack: Slack
    private let log: Logger

    private let queue = DispatchQueue(label: "commandQueue", qos: .background)

    init(karmaRepository: KarmaRepository,
         slack: Slack,
         log: Logger) {

        self.karmaRepository = karmaRepository
        self.slack = slack
        self.log = log
    }

    /// Returns a list of all `Karma`s.
    func all(_ req: Request) throws -> Future<[Karma]> {
        return karmaRepository.all()
    }

    func command(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(Command.self).flatMap { _ in
            try Leaderboard(text: "leaderboard").encode(for: req)
        }
    }

    /// Saves a decoded `Karma` to the database.
    func create(_ req: Request, content: Karma) throws -> Future<Karma> {
        return karmaRepository.save(karma: content)
    }

    /// Saves a decoded `Karma` to the database.
    func update(_ req: Request, content: Karma) throws -> Future<Karma> {
        return karmaRepository.save(karma: content)
    }

    func find(_ req: Request) throws -> Future<Karma> {
        let id = try req.parameters.next(String.self)
        return karmaRepository.find(id: id).unwrap(or: Abort(.notFound))
    }

    func karmaCommand(_ req: Request, content: Command) throws -> Future<HTTPStatus> {
        self.queue.async {
            do {
                let _ = try self.processKarmaCommand(req, content: content)
            } catch
            {
                self.log.debug("Could not process karma command: \(error)")
            }
        }

        return req.future(HTTPStatus.ok)
    }

    private func processKarmaCommand(_ req: Request, content: Command) throws -> Future<Response> {
        let client = try req.client()

        guard let responseUrl = content.response_url else {
            return req.future(error: Abort(.badRequest))
        }

        let userIds = karmaParser.usersFrom(message: content.text ?? "")
        guard !userIds.isEmpty else {
            return karmaRepository.find(id: content.user_id ?? "")
                .unwrap(or: Abort(.notFound))
                .flatMap { karma in
                    client.post(responseUrl) { beforePost in
                        let karmaMessage = KarmaMessage(user: karma.id ?? "", karma: karma.karma)
                        let karmaResponse = KarmaResponse(attachments: [karmaMessage.karmaAttachment()])
                        try beforePost.content.encode(json: karmaResponse)
                    }
            }
        }

        return karmaRepository.find(ids: userIds)
            .flatMap { karma -> Future<[KarmaAttachment]> in
                return req.future(karma.map { karma -> KarmaAttachment in
                    let message = KarmaMessage(user: karma.id ?? "", karma: karma.karma)
                    return message.karmaAttachment()
                })
            }
            .flatMap { attachments -> Future<Response> in
                return client.post(responseUrl) { beforePost in
                    let karmaResponse = KarmaResponse(attachments: attachments)
                    try beforePost.content.encode(json: karmaResponse)
            }
        }
    }
}

extension KarmaController: RouteCollection {
    func boot(router: Router) throws {
        router.get("karma", use: all)
        router.post(Karma.self, at:"karma", use: create)
        router.put(Karma.self, at:"karma", use: update)
        router.get("karma", String.parameter, use: find)
        router.post("command", use: command)
        router.post(Command.self, at: "command/karma", use: karmaCommand)
    }
}

extension KarmaController: ServiceType {
    static func makeService(for container: Container) throws -> KarmaController {
        let slack = try container.make(Slack.self)
        let karmaController = KarmaController(karmaRepository: try container.make(KarmaRepository.self),
                                              slack: slack,
                                              log: try container.make(Logger.self))

        slack.register(responder: karmaController, on: container)

        return karmaController
    }
}

extension KarmaController: SlackResponder {

    var eventTypes: [EventType] { return [.message] }

    func handleEvent(event: Event) {
        guard let message = event.text,
              let channelId = event.channel?.id,
              let sendingUser = event.user?.id else {
            return
        }

        let karmaMessages = karmaParser.karmaMessages(from: message)

        karmaMessages.forEach { karmaMessage in
            let slack = self.slack
            let repository = self.karmaRepository
            let log = self.log

            guard karmaMessage.user != sendingUser else {
                let errorMessage = "You can't adjust karma for yourself! "
                try! slack.sendErrorMessage(text: errorMessage, channelId: channelId, user: sendingUser)
                return
            }

            // Update karma
            let karmaRequest = karmaRepository.find(id: karmaMessage.user)
                .unwrap(or: Abort(.notFound))
                .flatMap { storedKarma in
                    storedKarma.karma += karmaMessage.karma
                    return repository.save(karma: storedKarma)
                }.catchFlatMap { _ in
                    repository.save(karma: karmaMessage.karmaData())
                }

            // Respond with the updated karam
            karmaRequest
                .thenThrowing { karma -> Void in
                    let attachment = karmaMessage.slackAttachment(with: karma.karma)
                    try slack.sendMessage(text: karmaMessage.slackUser(), channelId: channelId, attachments: [attachment])
                }.catchMap { error in
                    let errorMessage = "Something went wrong. Please try again"
                    try slack.sendErrorMessage(text: errorMessage, channelId: channelId, user: sendingUser)
                }.catch {
                    log.error("Completely unhandled Karma error occurred. This is bad, so bad: \($0)")
                }
        }
    }
}
