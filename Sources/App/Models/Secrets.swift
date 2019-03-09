//
//  Secrets.swift
//  App
//
//  Created by Jacob Wilson on 2/22/19.
//

import Vapor

struct Secrets: Service, Equatable, Decodable {
    static let secretsFilename = "secrets.json"

    enum CodingKeys: String, CodingKey {
        case slackAppBotUserAPI = "BotUserAPIKey"
        case slackRequestSigningSecret = "SlackRequestSigningSecret"
        case onTapSecret = "OnTapSecret"
    }

    let slackAppBotUserAPI: String
    // Slash commands will be ignored if the secret is missing
    let slackRequestSigningSecret: String?
    let onTapSecret: String

    public static func detect() throws -> Secrets {
        let url = URL(fileURLWithPath: DirectoryConfig.detect().workDir).appendingPathComponent(Secrets.secretsFilename)

        // Local Secrets
        if let data = try? Data(contentsOf: url) {
            return try JSONDecoder().decode(Secrets.self, from: data)
        }

        // Container/Environment Secrets

        guard let slackAppBotUserAPI = Environment.get(.slackAppBotUserAPI) else {
            throw Abort(.internalServerError)
        }

        guard let onTapSecret = Environment.get(.onTapSecret) else {
            throw Abort(.internalServerError)
        }


    return Secrets(slackAppBotUserAPI: slackAppBotUserAPI,
                   slackRequestSigningSecret: Environment.get(.slackRequestSigningSecret),
                   onTapSecret: onTapSecret)
    }
}

extension Environment {
    typealias Key = Secrets.CodingKeys

    static func get(_ key: Environment.Key) -> String? {
        return get(key.rawValue)
    }
}
