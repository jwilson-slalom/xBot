//
//  slackRoutes.swift
//  App
//
//  Created by Allen Humphreys on 3/13/19.
//

import Vapor
import enum SlackKit.EventType

/// Register your application's slack routes here.
func slackRoutes(_ router: SlackRouter, _ container: Container) throws {
    try router.register(collection: try container.make(KarmaController.self))

    router.register(responder: try container.make(OnTapController.self), for: [.message])
}
