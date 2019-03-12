//
//  TestStatusRepository.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/12/19.
//

@testable import App
import Vapor
import XCTest

final class TestStatusRepository: KarmaStatusRepository {

    private let group: MultiThreadedEventLoopGroup

    init() {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    func all() -> EventLoopFuture<[KarmaStatus]> {
        return group.future([KarmaStatus(id: "Id", count: 3, type: .user)])
    }

    func save(karma: KarmaStatus) -> EventLoopFuture<KarmaStatus> {
        return group.future(karma)
    }

    func find(id: String) -> EventLoopFuture<KarmaStatus?> {
        return group.future(KarmaStatus(id: "Id", count: 3, type: .user))
    }

    func find(ids: [String]) -> EventLoopFuture<[KarmaStatus]> {
        return group.future([KarmaStatus(id: "Id", count: 3, type: .user)])
    }
}

extension TestStatusRepository {
    static let serviceSupports: [Any.Type] = [KarmaStatusRepository.self]

    static func makeService(for worker: Container) throws -> TestStatusRepository {
        return .init()
    }
}

