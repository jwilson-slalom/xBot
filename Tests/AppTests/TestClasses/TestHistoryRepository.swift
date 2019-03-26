//
//  TestHistoryRepository.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/12/19.
//

@testable import App
import Vapor
import XCTest

final class TestHistoryRepository: KarmaSlackHistoryRepo {

    private let group: MultiThreadedEventLoopGroup

    var multiHistory: [KarmaSlackHistory]?
    var history: KarmaSlackHistory?

    init() {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    func all() -> Future<[KarmaSlackHistory]> {
        guard let history = multiHistory else {
            return group.future(error: TestHistoryError.noHistory)
        }
        return group.future(history)
    }
    
    func save(history: KarmaSlackHistory) -> Future<KarmaSlackHistory> {
        return group.future(history)
    }

    func find(id: Int) -> Future<KarmaSlackHistory?> {
        return group.future(history)
    }

    func find(ids: [Int]) -> Future<[KarmaSlackHistory]> {
        guard let history = multiHistory else {
            return group.future(error: TestHistoryError.noHistory)
        }
        return group.future(history)
    }
}

extension TestHistoryRepository {
    static let serviceSupports: [Any.Type] = [KarmaSlackHistoryRepository.self]

    static func makeService(for worker: Container) throws -> TestHistoryRepository {
        return .init()
    }
}

extension TestHistoryRepository {
    enum TestHistoryError: Error {
        case noHistory
    }

    func shutdown() throws {
        try group.syncShutdownGracefully()
    }
}

