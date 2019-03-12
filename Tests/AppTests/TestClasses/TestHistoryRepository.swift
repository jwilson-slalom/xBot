//
//  TestHistoryRepository.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/12/19.
//

@testable import App
import Vapor
import XCTest

final class TestHistoryRepository: KarmaSlackHistoryRepository {

    private let group: MultiThreadedEventLoopGroup

    init() {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    func all() -> Future<[KarmaSlackHistory]> {
        return group.future([KarmaSlackHistory(id: 0, karmaCount: 2, fromUser: "Jacob", karmaReceiver: "Allen", channel: "watercooler")])
    }
    
    func save(history: KarmaSlackHistory) -> Future<KarmaSlackHistory> {
        return group.future(history)
    }

    func find(id: Int) -> Future<KarmaSlackHistory?> {
        return group.future(KarmaSlackHistory(id: 0, karmaCount: 2, fromUser: "Jacob", karmaReceiver: "Allen", channel: "watercooler"))
    }

    func find(ids: [Int]) -> Future<[KarmaSlackHistory]> {
        return group.future([KarmaSlackHistory(id: 0, karmaCount: 2, fromUser: "Jacob", karmaReceiver: "Allen", channel: "watercooler")])
    }
}

extension TestHistoryRepository {
    static let serviceSupports: [Any.Type] = [KarmaSlackHistoryRepository.self]

    static func makeService(for worker: Container) throws -> TestHistoryRepository {
        return .init()
    }
}

