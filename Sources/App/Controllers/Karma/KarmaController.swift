import Vapor

/// Controls basic CRUD operations on `Karma`s.
final class KarmaController {

    let karmaStatusRepository: KarmaStatusRepository
    let karmaHistoryRepository: KarmaSlackHistoryRepository
    let slack: Slack
    let log: Logger

    let karmaParser = KarmaParser()

    init(karmaStatusRepository: KarmaStatusRepository,
         karmaHistoryRepository: KarmaSlackHistoryRepository,
         slack: Slack,
         log: Logger) {

        self.karmaStatusRepository = karmaStatusRepository
        self.karmaHistoryRepository = karmaHistoryRepository
        self.slack = slack
        self.log = log
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
        let slack = try container.make(Slack.self)
        let karmaController = KarmaController(karmaStatusRepository: try container.make(KarmaStatusRepository.self),
                                              karmaHistoryRepository: try container.make(KarmaSlackHistoryRepository.self),
                                              slack: slack,
                                              log: try container.make(Logger.self))

        slack.register(responder: karmaController, on: container)

        return karmaController
    }
}


