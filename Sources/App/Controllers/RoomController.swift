import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class RoomController {

    init() {

    }

    /// Returns a list of all `Todo`s.
    func all(_ req: Request) throws -> [String] {
        return [""]
    }
}

extension RoomController: RouteCollection {
    func boot(router: Router) throws {
        router.get("rooms", use: all)
    }
}

extension RoomController: ServiceType {
    static func makeService(for container: Container) throws -> RoomController {
        return RoomController()
    }
}
