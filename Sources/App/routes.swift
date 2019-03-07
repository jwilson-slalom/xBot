import Vapor

/// Register your application's routes here.
public func routes(_ router: Router, _ container: Container) throws {
    let roomController = try container.make(RoomController.self)
    try router.register(collection: roomController)

    let v1Group = router.grouped("v1")
    try v1Group.register(collection: try container.make(KarmaController.self))
    try v1Group.register(collection: try container.make(OnTapController.self))
    try v1Group.register(collection: try container.make(WelcomeController.self))

    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
}
