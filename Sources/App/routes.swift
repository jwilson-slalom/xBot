import Vapor

/// Register your application's routes here.
public func routes(_ router: Router, _ container: Container) throws {
    let todoController = try container.make(TodoController.self)
    try router.register(collection: todoController)

    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
}
