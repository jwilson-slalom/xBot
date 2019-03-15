import Vapor

/// Register your application's routes here.
public func routes(_ router: Router, _ container: Container) throws {
    let v1Group = router.grouped("v1")
    try v1Group.register(collection: try container.make(KarmaController.self))
    try v1Group.register(collection: try container.make(OnTapController.self))
    try v1Group.register(collection: try container.make(RoomController.self))
}
