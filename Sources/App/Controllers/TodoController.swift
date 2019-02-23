import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class TodoController {

    private let todoRepository: TodoRepository

    init(todoRepository: TodoRepository) {
        self.todoRepository = todoRepository
    }

    /// Returns a list of all `Todo`s.
    func all(_ req: Request) throws -> Future<[Todo]> {
        return todoRepository.all()
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Todo> {
        return try req.content.decode(Todo.self).flatMap { todo in
            return self.todoRepository.save(user: todo)
        }
    }
}

extension TodoController: RouteCollection {
    func boot(router: Router) throws {
        router.get("todos", use: all)
        router.post("todos", use: create)
    }
}

extension TodoController: ServiceType {
    static func makeService(for container: Container) throws -> TodoController {
        let todoRepository = try container.make(TodoRepository.self)
        return TodoController(todoRepository: todoRepository)
    }
}
