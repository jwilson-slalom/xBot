import Vapor
import class SlackKit.Event
import enum SlackKit.EventType

/// Controls basic CRUD operations on `Karma`s.
final class KarmaController {

    private let karmaRepository: KarmaRepository
    private let karmaParser = KarmaParser()
    private let slack: Slack

    init(karmaRepository: KarmaRepository,
         slack: Slack) {

        self.karmaRepository = karmaRepository
        self.slack = slack
    }

    /// Returns a list of all `Todo`s.
    func all(_ req: Request) throws -> Future<[Karma]> {
        return karmaRepository.all()
    }

    func command(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(Command.self).flatMap {  command in
            return try Leaderboard(text: "leaderboard").encode(for: req)
        }
    }

    /// Saves a decoded `Karma` to the database.
    func create(_ req: Request, content: Karma) throws -> Future<Karma> {
        return self.karmaRepository.save(karma: content)
    }

    /// Saves a decoded `Karma` to the database.
    func update(_ req: Request, content: Karma) throws -> Future<Karma> {
        return self.karmaRepository.save(karma: content)
    }

    func find(_ req: Request) throws -> Future<Karma> {
        let id = try req.parameters.next(String.self)
        return self.karmaRepository.find(id: id).map { almostKarma in
            if let karma = almostKarma {
                return karma
            }

            throw Abort(.notFound)
        }
    }
}

extension KarmaController: RouteCollection {
    func boot(router: Router) throws {
        router.get("karma", use: all)
        router.post(Karma.self, at:"karma", use: create)
        router.put(Karma.self, at:"karma", use: update)
        router.get("karma", String.parameter, use: find)
//        router.post(Command.self, at: "command", use: command)
        router.post("command", use: command)
    }
}

extension KarmaController: ServiceType {

    static func makeService(for container: Container) throws -> KarmaController {
        let slack = try container.make(Slack.self)
        let karmaController = KarmaController(karmaRepository: try container.make(KarmaRepository.self),
                                              slack: slack)

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

        guard let karmaMessage = karmaParser.karmaMessageFrom(message: message) else {
            return
        }

        guard karmaMessage.user != sendingUser else {
            // TODO: Send error message back to offending user 
            print("You can't adjust karma for yourself! Try spreading the wealth 😎")
            return
        }

        let karmaRequest = self.karmaRepository.find(id: karmaMessage.user).flatMap { almostKarma in
            if let karma = almostKarma {
                let updatedKarma = Karma(id: karma.id, karma: karma.karma + karmaMessage.karma)
                return self.karmaRepository.save(karma: updatedKarma)
            }

            throw Abort(.notFound)
        }.catchFlatMap { error in
            return self.karmaRepository.save(karma: karmaMessage.karmaData())
        }

        let slack = self.slack
        karmaRequest
            .do { karma in
                let attachment = karmaMessage.slackAttachment(with: karma.karma)
                try! slack.sendMessage(text: karmaMessage.slackUser(), channelId: channelId, attachments: [attachment])
            }.catch { error in
                let errorMessage = "Something went wrong. Please try again"
                try! slack.sendErrorMessage(text: errorMessage, channelId: channelId, user: sendingUser)
            }
    }
}
