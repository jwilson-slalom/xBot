import Vapor

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

    func handle(message: Message) throws {
        guard let sendingUser = message.sender else { return }

        let karmaMessages = karmaParser.karmaMessages(from: message.text)

        try karmaMessages.forEach { karmaMessage in
            let slack = self.slack
            let repository = self.karmaRepository
            let log = self.log

            guard karmaMessage.user != sendingUser else {
                let errorMessage = "You can't adjust karma for yourself! "
                try slack.send(message: message.response(with: errorMessage), onlyVisibleTo: sendingUser)
                return
            }

            // Update karma
            karmaRepository.find(id: karmaMessage.user)
                .unwrap(or: Abort(.notFound))
                .flatMap { storedKarma in
                    storedKarma.karma += karmaMessage.karma
                    return repository.save(karma: storedKarma)
                }.catchFlatMap { _ in
                    repository.save(karma: karmaMessage.karmaData())
                }.thenThrowing { karma -> Void in
                    let response = message.response(with: karmaMessage.slackUser(),
                                                    attachments: [karmaMessage.slackAttachment(with: karma.karma)])
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
