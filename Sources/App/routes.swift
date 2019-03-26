import Vapor
import Leaf

/// Register your application's routes here.
public func routes(_ router: Router, _ container: Container) throws {
    router.get("help") { request -> Future<View> in
        let slackRouter = try container.make(SlackRouter.self)

        let commands = slackRouter.registeredCommands
        return try request.view().render("help", HelpContext(title: "Help", commands: commands))
    }

    let v1Group = router.grouped("v1")
    try v1Group.register(collection: try container.make(KarmaController.self))
    try v1Group.register(collection: try container.make(OnTapController.self))
    try v1Group.register(collection: try container.make(RoomController.self))
}

struct HelpContext: Encodable {
    var title: String
    var commands: [CommandInfo]
}
