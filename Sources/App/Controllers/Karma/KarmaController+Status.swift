//
//  KarmaController+Status.swift
//  App
//
//  Created by Jacob Wilson on 3/7/19.
//

import Vapor

extension KarmaController {
    func registerStatusRoutes(on router: Router) {
        router.get("status", use: allStatus)
        router.get("status", String.parameter, use: findStatus)

        router.post(KarmaStatus.self, at:"status", use: createStatus)
        router.put(KarmaStatus.self, at:"status", use: updateStatus)
    }

    /// Returns a list of all `KarmaStatus`s.
    func allStatus(_ req: Request) throws -> Future<[KarmaStatus]> {
        return karmaStatusRepository.all()
    }

    func findStatus(_ req: Request) throws -> Future<KarmaStatus> {
        let id = try req.parameters.next(String.self)
        return karmaStatusRepository.find(id: id).unwrap(or: Abort(.notFound))
    }

    /// Saves a decoded `KarmaStatus` to the database.
    func createStatus(_ req: Request, content: KarmaStatus) throws -> Future<KarmaStatus> {
        return karmaStatusRepository.save(karma: content)
    }

    /// Saves a decoded `KarmaStatus` to the database.
    func updateStatus(_ req: Request, content: KarmaStatus) throws -> Future<KarmaStatus> {
        return karmaStatusRepository.save(karma: content)
    }
}
