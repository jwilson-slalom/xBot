//
//  KarmaStatusRepository.swift
//  App
//
//  Created by Jacob Wilson on 2/22/19.
//

import Vapor
import Fluent
import FluentPostgreSQL

protocol KarmaStatusRepository: ServiceType {
    func all() -> Future<[KarmaStatus]>
    func save(karma: KarmaStatus) -> Future<KarmaStatus>
    func find(id: String) -> Future<KarmaStatus?>
    func find(ids: [String]) -> Future<[KarmaStatus]>
}

extension Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}

final class PostgresKarmaStatusRepository: KarmaStatusRepository {

    let db: PostgreSQLDatabase.ConnectionPool

    init(_ db: PostgreSQLDatabase.ConnectionPool) {
        self.db = db
    }

    func all() -> Future<[KarmaStatus]> {
        return db.withConnection { connection in
            KarmaStatus.query(on: connection).all()
        }
    }

    func save(karma: KarmaStatus) -> Future<KarmaStatus> {
        return db.withConnection { connection in
            karma.create(on: connection).catchFlatMap { _ in
                karma.update(on: connection)
            }
        }
    }

    func find(id: String) -> Future<KarmaStatus?> {
        return db.withConnection { connection in
            KarmaStatus.find(id, on: connection)
        }
    }

    func find(ids: [String]) -> Future<[KarmaStatus]> {
        return db.withConnection { connection in
            KarmaStatus.query(on: connection).filter(\.id ~~ ids).all()
        }
    }
}

//MARK: - ServiceType conformance
extension PostgresKarmaStatusRepository {
    static let serviceSupports: [Any.Type] = [KarmaStatusRepository.self]

    static func makeService(for worker: Container) throws -> PostgresKarmaStatusRepository {
        return .init(try worker.connectionPool(to: .psql))
    }
}
