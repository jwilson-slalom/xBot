//
//  TodoRepository.swift
//  App
//
//  Created by Jacob Wilson on 2/22/19.
//

import Vapor
import FluentSQLite

protocol TodoRepository: ServiceType {
    func all() -> Future<[Todo]>
    func save(user: Todo) -> Future<Todo>
}

extension Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}

final class SQLiteTodoRepository: TodoRepository {
    let db: SQLiteDatabase.ConnectionPool

    init(_ db: SQLiteDatabase.ConnectionPool) {
        self.db = db
    }

    func all() -> Future<[Todo]> {
        return db.withConnection { conn in
            return Todo.query(on: conn).all()
        }
    }

    func save(user: Todo) -> Future<Todo> {
        return db.withConnection { conn in
            return user.save(on: conn)
        }
    }
}

//MARK: - ServiceType conformance
extension SQLiteTodoRepository {
    static let serviceSupports: [Any.Type] = [TodoRepository.self]

    static func makeService(for worker: Container) throws -> SQLiteTodoRepository {
        return .init(try worker.connectionPool(to: .sqlite))
    }
}
