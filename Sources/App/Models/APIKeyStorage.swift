//
//  APIKeyStorage.swift
//  App
//
//  Created by Jacob Wilson on 2/22/19.
//

import Vapor

struct APIKeyStorage: Equatable {
    let botUserApiKey: String
}

extension Environment {
    enum Key: String {
        case slackAppBotUserAPI = "BotUserAPIKey"
    }

    static func get(_ key: Environment.Key) -> String? {
        return get(key.rawValue)
    }
}

extension APIKeyStorage: ServiceType {
    static let secretsFilename = "secrets.json"

    static func makeService(for container: Container) throws -> APIKeyStorage {
        let workingDirectoryPath = try container.make(DirectoryConfig.self).workDir
        let url = URL(fileURLWithPath: workingDirectoryPath).appendingPathComponent(secretsFilename)

        if let data = try? Data(contentsOf: url) {
            if let secrets = try? JSONDecoder().decode([String: String].self, from: data) {

                for (k, v) in secrets {
                    setenv(k, v, 1)
                }
            }
        }

        guard let botUserApiKey = Environment.get(.slackAppBotUserAPI) else {
            throw Abort(.internalServerError)
        }

        return APIKeyStorage(botUserApiKey: botUserApiKey)
    }
}
