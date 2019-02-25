//
//  APIKeyStorage.swift
//  App
//
//  Created by Jacob Wilson on 2/22/19.
//

import Vapor

struct APIKeyStorage {
    let botUserApiKey: String
}

extension APIKeyStorage: ServiceType {
    static func makeService(for container: Container) throws -> APIKeyStorage {
        guard let botUserApiKey = Environment.get("BotUserAPIKey") else { throw Abort(.internalServerError) }
        return APIKeyStorage(botUserApiKey: botUserApiKey)
    }
}
