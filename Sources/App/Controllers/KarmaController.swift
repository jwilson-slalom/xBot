import Vapor
import class SlackKit.Event
import enum SlackKit.EventType

/// Controls basic CRUD operations on `Karma`s.
final class KarmaController {

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
}

extension KarmaController: RouteCollection {
    func boot(router: Router) throws {
        router.get("karma", use: all)
        router.post("karma", use: create)
        router.put("karma", use: update)
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
        print("handleEvent in KarmaController")

        guard let message = event.text else {
            return
        }

        guard let karmaMessage = karmaParser.karmaMessageFrom(message: message) else {
            return
        }

        let karmaRequest = self.karmaRepository.save(karma: karmaMessage.karmaData())
        karmaRequest.addAwaiter { result in
            guard let _ = result.result,
                result.error == nil else {
                    return
            }

            try! slack.sendMessage(text: karmaMessage.slackUser(), channelId: event.channel!.id!, attachments: [karmaMessage.slackAttachment()])
        }
    }
}
