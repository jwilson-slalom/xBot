//
//  KarmaHistoryRepository.swift
//  App
//
//  Created by Jacob Wilson on 3/7/19.
//

import Vapor
import Fluent
import FluentSQLite

protocol KarmaSlackHistoryRepository: ServiceType {
    func all() -> Future<[KarmaSlackHistory]>
    func save(history: KarmaSlackHistory) -> Future<KarmaSlackHistory>
    func find(id: Int) -> Future<KarmaSlackHistory?>
    func find(ids: [Int]) -> Future<[KarmaSlackHistory]>
}

final class SQLiteKarmaSlackHistoryRepository: KarmaSlackHistoryRepository {

    let db: SQLiteDatabase.ConnectionPool

    init(_ db: SQLiteDatabase.ConnectionPool) {
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
extension SQLiteKarmaSlackHistoryRepository {
    static let serviceSupports: [Any.Type] = [KarmaSlackHistoryRepository.self]

    static func makeService(for worker: Container) throws -> SQLiteKarmaSlackHistoryRepository {
        return .init(try worker.connectionPool(to: .sqlite))
    }
}
