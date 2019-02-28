//
//  OnTapController.swift
//  App
//
//  Created by Allen Humphreys on 2/28/19.
//

import Vapor
import HTTP
import Routing
import class SlackKit.Event
import enum SlackKit.EventType

final class OnTapController: RouteCollection, ServiceType {

    static func makeService(for container: Container) throws -> OnTapController {
        return OnTapController()
    }

    func boot(router: Router) throws {
        let onTapGroup = router.grouped("/ontap")
        onTapGroup.post(Beer.self, at: "/taps", use: update)
        onTapGroup.get("/taps", use: getBeers)
    }

    func getBeers(request: Request) -> Beer {
        return Beer()
    }

    func update(req: Request, content: Beer) throws -> EmptyCollection<Void> {
        return EmptyCollection<Void>()
    }
}

extension OnTapController: SlackHandler {

    var eventTypes: [EventType] { return [.message] }

    func handleEvent(event: Event, slack: SlackMessageSender) {

        if event.message?.text?.contains("beer") ?? false {
            try! slack.sendMessage(text: "Maybe you should try one of these beers...", channelId: event.channel!.id!)
        }
    }
}

extension EmptyCollection: ResponseEncodable where Element == Void {

    public func encode(for req: Request) throws -> EventLoopFuture<Response> {
        return req.response().encode(status: .ok, headers: HTTPHeaders(), for: req)
    }
}
