import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class KarmaController {

    private let karmaRepository: KarmaRepository

    init(todoRepository: KarmaRepository) {
        self.karmaRepository = todoRepository
    }

    /// Returns a list of all `Todo`s.
    func all(_ req: Request) throws -> Future<[Karma]> {
        return karmaRepository.all()
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Karma> {
        return try req.content.decode(Karma.self).flatMap { karma in
            return self.karmaRepository.save(karma: karma)
        }
    }
}

extension KarmaController: RouteCollection {
    func boot(router: Router) throws {
        router.get("karma", use: all)
        router.post("karma", use: create)
    }
}

extension KarmaController: ServiceType {
    static func makeService(for container: Container) throws -> KarmaController {
        let todoRepository = try container.make(KarmaRepository.self)
        return KarmaController(todoRepository: todoRepository)
    }
}
