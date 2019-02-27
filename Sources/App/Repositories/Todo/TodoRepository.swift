//
//  TodoRepository.swift
//  App
//
//  Created by Jacob Wilson on 2/22/19.
//

import Vapor
import FluentPostgreSQL

protocol TodoRepository: ServiceType {
    func all() -> Future<[Todo]>
    func save(user: Todo) -> Future<Todo>
}

extension Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}

final class PostgresTodoRepository: TodoRepository {
    let db: PostgreSQLDatabase.ConnectionPool

    init(_ db: PostgreSQLDatabase.ConnectionPool) {
        self.db = db
    }

    func all() -> Future<[Todo]> {
        return db.withConnection { conn in
            Todo.query(on: conn).all()
        }
    }

    func save(user: Todo) -> Future<Todo> {
        return db.withConnection { conn in
            user.save(on: conn)
        }
    }
}

//MARK: - ServiceType conformance
extension PostgresTodoRepository {
	static let serviceSupports: [Any.Type] = [TodoRepository.self]

	static func makeService(for worker: Container) throws -> PostgresTodoRepository {
		return .init(try worker.connectionPool(to: .psql))
	}
}
