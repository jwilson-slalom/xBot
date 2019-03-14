//
//  KarmaStatusRepository.swift
//  App
//
//  Created by Jacob Wilson on 2/22/19.
//

import Vapor
import Fluent
import FluentPostgreSQL

protocol KarmaStatusRepo: ServiceType {
    func all() -> Future<[KarmaStatus]>
    func save(karma: KarmaStatus) -> Future<KarmaStatus>
    func find(id: String) -> Future<KarmaStatus?>
    func find(ids: [String]) -> Future<[KarmaStatus]>
    func top(count: Int) -> Future<[KarmaStatus]>
}

extension Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}

final class KarmaStatusRepository: KarmaStatusRepo {

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

    func top(count: Int) -> Future<[KarmaStatus]> {
        return db.withConnection { connection in
            KarmaStatus.query(on: connection).sort(\.count, .descending).range(..<count).all()
        }
    }
}

//MARK: - ServiceType conformance
extension KarmaStatusRepository {
    static let serviceSupports: [Any.Type] = [KarmaStatusRepo.self]

    static func makeService(for worker: Container) throws -> KarmaStatusRepository {
        return .init(try worker.connectionPool(to: .psql))
    }
}
