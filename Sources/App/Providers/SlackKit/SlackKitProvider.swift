//
//  SlackKitProvider.swift
//  App
//
//  Created by Jacob Wilson on 2/23/19.
//

import Vapor

public struct SlackKitProvider: Provider {
    public func register(_ services: inout Services) throws {
        services.register(SlackKitService.self)
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        let service = try container.make(SlackKitService.self)
        service.registerRTMConnection()
        return .done(on: container)
    }
}
