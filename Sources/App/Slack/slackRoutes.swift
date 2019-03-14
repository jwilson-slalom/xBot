//
//  slackRoutes.swift
//  App
//
//  Created by Allen Humphreys on 3/13/19.
//

import Vapor

/// Register your application's slack routes here.
func slackRoutes(_ router: SlackRouter, _ container: Container) throws {

    router.register(responder: try container.make(KarmaController.self), for: [.message])
    router.register(responder: try container.make(OnTapController.self), for: [.message])
}
