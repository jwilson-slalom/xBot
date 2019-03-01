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

    private let onTapRepository: OnTapRepository

    static func makeService(for container: Container) throws -> OnTapController {
        return OnTapController(onTapRepository: try container.make(OnTapRepository.self))
    }

    init(onTapRepository: OnTapRepository) {
        self.onTapRepository = onTapRepository
    }

    func boot(router: Router) throws {
        let onTapGroup = router.grouped("/ontap")
        onTapGroup.post(Beer.self, at: "/update", Tap.parameter, use: update)
        onTapGroup.get("/taps", use: getBeers)
    }

    func getBeers(request: Request) -> EventLoopFuture<[Beer]> {
        return onTapRepository.all()
    }

    func update(req: Request, content: Beer) throws -> EventLoopFuture<[Beer]> {
//        var parameter: Tap = try req.parameters.next()

        return try req.content.decode(Beer.self)
            .then { beer in
                self.onTapRepository.save(beer: [beer])
            }
    }
}

extension OnTapController: SlackHandler {

    var eventTypes: [EventType] { return [.message] }

    func handleEvent(event: Event, slack: SlackMessageSender) {

        if event.message?.text?.contains("beer") ?? false {

            onTapRepository
                .all()
                .do { beers in
                    try! slack.sendMessage(
                        text: "Maybe you should try one of these beers either: \(beers[0]) or \(beers[1])",
                        channelId: event.channel!.id!
                    )
                }
                .catch { error in
                    print("Failed to send slack response: \(error)")
                }
        }
    }
}

extension EmptyCollection: ResponseEncodable where Element == Void {

    public func encode(for req: Request) throws -> EventLoopFuture<Response> {
        return req.response().encode(status: .ok, headers: HTTPHeaders(), for: req)
    }
}
