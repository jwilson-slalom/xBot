import Vapor

/// Controls basic CRUD operations on `Karma`s.
final class KarmaController {

    let karmaStatusRepository: KarmaStatusRepository
    let karmaHistoryRepository: KarmaSlackHistoryRepository
    let slack: Slack
    let log: Logger
    let secrets: Secrets

    let karmaParser = KarmaParser()

    init(karmaStatusRepository: KarmaStatusRepository,
         karmaHistoryRepository: KarmaSlackHistoryRepository,
         slack: Slack,
         log: Logger,
         secrets: Secrets) {

        self.karmaStatusRepository = karmaStatusRepository
        self.karmaHistoryRepository = karmaHistoryRepository
        self.slack = slack
        self.log = log
        self.secrets = secrets
    }
}

extension KarmaController: RouteCollection {
    func boot(router: Router) throws {
        registerSlackRoutes(on: router)

//        Don't need to enable these right now
//
//        registerStatusRoutes(on: router)
//        registerHistoryRoutes(on: router)
    }
}

extension KarmaController: ServiceType {
    static func makeService(for container: Container) throws -> KarmaController {
        return KarmaController(karmaStatusRepository: try container.make(),
                               karmaHistoryRepository: try container.make(),
                               slack: try container.make(),
                               log: try container.make(),
                               secrets: try container.make())
    }
}
