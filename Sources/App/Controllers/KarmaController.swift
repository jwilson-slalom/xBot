import Vapor
import class SlackKit.Event
import enum SlackKit.EventType

/// Controls basic CRUD operations on `Karma`s.
final class KarmaController {

    var genericMessageSender: SlackMessageSender?

    private let karmaRepository: KarmaRepository
    private let karmaParser: KarmaParser

    init(karmaRepository: KarmaRepository,
         karmaParser: KarmaParser) {

        self.karmaRepository = karmaRepository
        self.karmaParser = karmaParser
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
    func create(_ req: Request) throws -> Future<Karma> {
        return try req.content.decode(Karma.self).flatMap { karma in
            return self.karmaRepository.save(karma: karma)
        }
    }

    /// Saves a decoded `Karma` to the database.
    func update(_ req: Request) throws -> Future<Karma> {
        return try req.content.decode(Karma.self).flatMap { karma in
            return self.karmaRepository.save(karma: karma)
        }
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
        router.post("karma", use: create)
        router.put("karma", use: update)
        router.get("karma", String.parameter, use: find)
//        router.post(Command.self, at: "command", use: command)
        router.post("command", use: command)
    }
}

extension KarmaController: ServiceType {
    static func makeService(for container: Container) throws -> KarmaController {
        let karmaRepository = try container.make(KarmaRepository.self)
        let karmaParser = try container.make(KarmaParser.self)

        return KarmaController(karmaRepository: karmaRepository, karmaParser: karmaParser)
    }
}

extension KarmaController: SlackHandler {

    var eventTypes: [EventType] { return [.message] }

    func handleEvent(event: Event, slack: SlackMessageSender) {
        guard let message = event.text else {
            return
        }

        guard let karmaMessage = karmaParser.karmaMessageFrom(message: message) else {
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

        karmaRequest.addAwaiter { result in
            guard let karma = result.result, result.error == nil else {
                return
            }

            let attachment = karmaMessage.slackAttachment(with: karma.karma)
            try! slack.sendMessage(text: karmaMessage.slackUser(), channelId: event.channel!.id!, attachments: [attachment])
        }
    }
}
