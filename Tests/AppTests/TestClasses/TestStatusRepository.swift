//
//  TestStatusRepository.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/12/19.
//

@testable import App
import Vapor
import XCTest

final class TestStatusRepository: KarmaStatusRepo {

    private let group: MultiThreadedEventLoopGroup

    var statuses: [KarmaStatus]?
    var status: KarmaStatus?
    var error: TestStatusError?

    init() {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    func all() -> EventLoopFuture<[KarmaStatus]> {
        guard let statuses = statuses else {
            return group.future(error: TestStatusError.noStatuses)
        }
        return group.future(statuses)
    }

    func save(karma: KarmaStatus) -> EventLoopFuture<KarmaStatus> {
        return error == nil ? group.future(karma) : group.future(error: error!)
    }

    func find(id: String) -> EventLoopFuture<KarmaStatus?> {
        return group.future(status)
    }

    func find(ids: [String]) -> EventLoopFuture<[KarmaStatus]> {
        guard let statuses = statuses else {
            return group.future(error: TestStatusError.noStatuses)
        }
        return group.future(statuses)
    }

    func top(count: Int) -> EventLoopFuture<[KarmaStatus]> {
        guard let statuses = statuses else {
            return group.future(error: TestStatusError.noStatuses)
        }
        return group.future(statuses)
    }
}

extension TestStatusRepository {
    static let serviceSupports: [Any.Type] = [KarmaStatusRepository.self]

    static func makeService(for worker: Container) throws -> TestStatusRepository {
        return .init()
    }
}

extension TestStatusRepository {
    enum TestStatusError: Error {
        case noStatuses
        case badRepo
    }

    func shutdown() throws {
        try group.syncShutdownGracefully()
    }
}

