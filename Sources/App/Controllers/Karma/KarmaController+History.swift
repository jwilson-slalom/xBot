//
//  KarmaController+History.swift
//  App
//
//  Created by Jacob Wilson on 3/7/19.
//

import Vapor

extension KarmaController {
    func registerHistoryRoutes(on router: Router) {
        router.get("history", use: allHistory)

        router.post(KarmaSlackHistory.self, at:"history", use: createHistory)
    }

    /// Returns a list of all `KarmaSlackHistory`s.
    func allHistory(_ req: Request) throws -> Future<[KarmaSlackHistory]> {
        return karmaHistoryRepository.all()
    }


    /// Saves a decoded `KarmaSlackHistory` to the database.
    func createHistory(_ req: Request, content: KarmaSlackHistory) throws -> Future<KarmaSlackHistory> {
        return karmaHistoryRepository.save(history: content)
    }
}
