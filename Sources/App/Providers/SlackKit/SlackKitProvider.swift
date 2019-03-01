//
//  SlackKitProvider.swift
//  App
//
//  Created by Jacob Wilson on 2/23/19.
//

import Vapor

fileprivate(set) var slackKitService: SlackKitService!

public final class SlackKitProvider: Provider {


    public func register(_ services: inout Services) throws {
        services.register(SlackKitService.self)
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        let service = try container.make(SlackKitService.self)
        slackKitService = service

        service.handlers.append(try container.make(OnTapController.self))
        service.handlers.append(try container.make(KarmaController.self))

        service.registerRTMConnection()

        return .done(on: container)
    }
}
