import Vapor

/// Controls basic CRUD operations on `Karma`s.
final class KarmaController {

    let karmaStatusRepository: KarmaStatusRepository
    let karmaHistoryRepository: KarmaSlackHistoryRepository
    let karmaParser: KarmaParser
    let slack: SlackMessageSender
    let log: Logger
    let secrets: Secrets

    init(karmaStatusRepository: KarmaStatusRepository,
         karmaHistoryRepository: KarmaSlackHistoryRepository,
         karmaParser: KarmaParser,
         slack: SlackMessageSender,
         log: Logger,
         secrets: Secrets) {

        self.karmaStatusRepository = karmaStatusRepository
        self.karmaHistoryRepository = karmaHistoryRepository
        self.karmaParser = karmaParser
        self.slack = slack
        self.log = log
        self.secrets = secrets
    }
}

extension KarmaController: RouteCollection {
    func boot(router: Router) throws {
        registerStatusRoutes(on: router)
        registerHistoryRoutes(on: router)
        registerSlackRoutes(on: router)
    }
}

extension KarmaController: ServiceType {
    static func makeService(for container: Container) throws -> KarmaController {
        let slack = try container.make(SlackMessageSender.self)
        let karmaController = KarmaController(karmaStatusRepository: try container.make(),
                                              karmaHistoryRepository: try container.make(),
                                              karmaParser: KarmaMessageParser(),
                                              slack: slack,
                                              log: try container.make(),
                                              secrets: try container.make())

        if let slack = slack as? Slack {
            slack.register(responder: karmaController, on: container)
        }

        return karmaController
    }
}


