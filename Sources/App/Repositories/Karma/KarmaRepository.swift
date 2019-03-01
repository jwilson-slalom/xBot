//
//  KarmaRepository.swift
//  App
//
//  Created by Jacob Wilson on 2/22/19.
//

import Vapor
import FluentSQLite

protocol KarmaRepository: ServiceType {
    func all() -> Future<[Karma]>
    func save(karma: Karma) -> Future<Karma>
    func find(id: String) -> Future<Karma?>
}

extension Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}

final class SQLiteKarmaRepository: KarmaRepository {

    let db: SQLiteDatabase.ConnectionPool

    init(_ db: SQLiteDatabase.ConnectionPool) {
        self.db = db
    }

    func all() -> Future<[Karma]> {
        return db.withConnection { conn in
            return Karma.query(on: conn).all()
        }
    }

    func save(karma: Karma) -> Future<Karma> {
        return db.withConnection { conn in
			return karma.create(on: conn).catchFlatMap { error in
				return karma.update(on: conn)
			}
		}
    }

    func find(id: String) -> Future<Karma?> {
        return db.withConnection { conn in
            return Karma.find(id, on: conn)
        }
    }
}

//MARK: - ServiceType conformance
extension SQLiteKarmaRepository {
    static let serviceSupports: [Any.Type] = [KarmaRepository.self]

    static func makeService(for worker: Container) throws -> SQLiteKarmaRepository {
        return .init(try worker.connectionPool(to: .sqlite))
    }
}
