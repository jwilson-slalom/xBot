//
//  KarmaHistoryRepository.swift
//  App
//
//  Created by Jacob Wilson on 3/7/19.
//

import Vapor
import Fluent
import FluentPostgreSQL

protocol KarmaSlackHistoryRepo: ServiceType {
    func all() -> Future<[KarmaSlackHistory]>
    func save(history: KarmaSlackHistory) -> Future<KarmaSlackHistory>
    func find(id: Int) -> Future<KarmaSlackHistory?>
    func find(ids: [Int]) -> Future<[KarmaSlackHistory]>
}

final class KarmaSlackHistoryRepository: KarmaSlackHistoryRepo {

    let db: PostgreSQLDatabase.ConnectionPool

    init(_ db: PostgreSQLDatabase.ConnectionPool) {
        self.db = db
    }

    func all() -> Future<[KarmaSlackHistory]> {
        return db.withConnection { connection in
            KarmaSlackHistory.query(on: connection).all()
        }
    }

    func save(history: KarmaSlackHistory) -> Future<KarmaSlackHistory> {
        return db.withConnection { connection in
            history.create(on: connection).catchFlatMap { _ in
                history.update(on: connection)
            }
        }
    }

    func find(id: Int) -> Future<KarmaSlackHistory?> {
        return db.withConnection { connection in
            KarmaSlackHistory.find(id, on: connection)
        }
    }

    func find(ids: [Int]) -> Future<[KarmaSlackHistory]> {
        return db.withConnection { connection in
            KarmaSlackHistory.query(on: connection).filter(\.id ~~ ids).all()
        }
    }
}

//MARK: - ServiceType conformance
extension KarmaSlackHistoryRepository {
    static let serviceSupports: [Any.Type] = [KarmaSlackHistoryRepo.self]

    static func makeService(for worker: Container) throws -> KarmaSlackHistoryRepository {
        return .init(try worker.connectionPool(to: .psql))
    }
}
