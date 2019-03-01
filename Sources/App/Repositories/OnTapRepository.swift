//
//  OnTapRepository.swift
//  App
//
//  Created by Allen Humphreys on 2/28/19.
//

import Vapor
import FluentSQLite
import DatabaseKit

protocol OnTapRepository: ServiceType {
    func all() -> Future<[Beer]>
    func save(beer: [Beer]) -> Future<[Beer]>
}

//extension Database {
//    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
//}

final class SQLiteOnTapRepository: OnTapRepository {

    let db: SQLiteDatabase.ConnectionPool

    init(_ db: SQLiteDatabase.ConnectionPool) {
        self.db = db
    }

    func all() -> Future<[Beer]> {
        return db.withConnection { conn in
            return Beer.query(on: conn).all()
        }
    }

    func save(beer: [Beer]) -> EventLoopFuture<[Beer]> {
        return db.withConnection { conn in

            var futures = [Future<Beer>]()
            for b in beer {
                futures.append(
                    b.create(on: conn)
                     .catchFlatMap { _ in b.update(on: conn) }
                )
            }

            return EventLoopFuture.reduce([Beer](), futures, eventLoop: conn.eventLoop) {
                var beers = $0
                beers.append($1)
                return beers
            }
        }
    }
}

//MARK: - ServiceType conformance
extension SQLiteOnTapRepository {
    static let serviceSupports: [Any.Type] = [OnTapRepository.self]

    static func makeService(for worker: Container) throws -> SQLiteOnTapRepository {
        return SQLiteOnTapRepository(try worker.connectionPool(to: .onTap))
    }
}
