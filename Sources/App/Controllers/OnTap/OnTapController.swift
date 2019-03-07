//
//  OnTapController.swift
//  App
//
//  Created by Allen Humphreys on 2/28/19.
//

import Vapor

private let iPadDeviceID = "21F17F00-A94B-4BE9-A03D-BA6A20D709FC"

final class OnTapController {

    let slack: Slack
    let log: Logger

    init(slackClient: Slack, logger: Logger) {
        self.slack = slackClient
        self.log = logger
    }
}

extension OnTapController: ServiceType {

    static func makeService(for container: Container) throws -> OnTapController {
        let slack = try container.make(Slack.self)
        let onTap = OnTapController(slackClient: slack, logger: try container.make())
        slack.register(responder: onTap, on: container)

        return onTap
    }
}

// MARK: - HTTP Route Handling

extension OnTapController: RouteCollection {

    func boot(router: Router) throws {
        let onTapGroup = router.grouped("/ontap")
        onTapGroup.post(Beer.self, at: "/tap", Tap.parameter, use: update)
        onTapGroup.delete("/tap", Tap.parameter, use: delete)
        onTapGroup.get("/taps", use: getBeers)
    }

    func getBeers(request: Request) -> KegSystem {
        return OnTapMemory.kegSystem
    }

    func update(request: Request, beer: Beer) throws -> EventLoopFuture<Response> {
        return try update(request: request, beer: Optional(beer))
    }

    func delete(request: Request) throws -> EventLoopFuture<Response> {
        return try update(request: request, beer: nil)
    }

    func update(request: Request, beer: Beer?) throws -> EventLoopFuture<Response> {
        guard let deviceID = request.http.headers.firstValue(name: .onTapDeviceIdentifier),
            deviceID == iPadDeviceID else {

            log.error("Unrecognized device attempted to update tap")
            return request.response().encode(status: .unauthorized, for: request)
        }

        let tap: Tap
        do {
            tap = try request.parameters.next(Tap.self)
        } catch let error as RoutingError {
            log.error("url path parameter decoding failed \(error)")
            return request.response().encode(status: .badRequest, for: request)
        }

        log.debug("Received: \(tap) tap \(beer?.name.uppercased() ?? "<nil>")")

        if OnTapMemory.set(beer: beer, on: tap) {
            log.debug("Changed: \(tap.rawValue.capitalized) tap to: \(beer?.name ?? "<nil>")")

            try notifySlackOfNewBeer(beer, on: tap)
        }

        return OnTapMemory.kegSystem.encode(status: .ok, for: request)
    }
}

private extension HTTPHeaderName {
    static let onTapDeviceIdentifier = HTTPHeaderName("x-device-identifier")
}
