//
//  OnTapController.swift
//  App
//
//  Created by Allen Humphreys on 2/28/19.
//

import Crypto
import Vapor

final class OnTapController {

    let slack: Slack
    let log: Logger
    let secrets: Secrets

    init(slack: Slack, logger: Logger, secrets: Secrets) {
        self.slack = slack
        self.log = logger
        self.secrets = secrets
    }
}

extension OnTapController: ServiceType {

    static func makeService(for container: Container) throws -> OnTapController {
        return OnTapController(slack: try container.make(), logger: try container.make(), secrets: try container.make())
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

    func update(request: Request, beer: Beer) throws -> Response {
        return try update(request: request, beer: Optional(beer))
    }

    func delete(request: Request) throws -> Response {
        return try update(request: request, beer: nil)
    }

    func update(request: Request, beer: Beer?) throws -> Response {
        guard let deviceID = request.http.headers[.onTapDeviceIdentifier].first,
            deviceID.secureCompare(to: secrets.onTapSecret) else {

            log.warning("Invalid onTap secret provided by client")
            return request.response(status: .unauthorized)
        }

        let tap: Tap
        do {
            tap = try request.parameters.next(Tap.self)
        } catch let error as RoutingError {
            log.error("url path parameter decoding failed \(error)")
            return request.response(status: .badRequest)
        }

        log.debug("Received: \(tap) tap \(beer?.name.uppercased() ?? "<nil>")")

        if OnTapMemory.set(beer: beer, on: tap) {
            log.debug("Changed: \(tap.rawValue.capitalized) tap to: \(beer?.name ?? "<nil>")")

            try notifySlackOfNewBeer(beer, on: tap)
        }

        return try request.response(content: OnTapMemory.kegSystem)
    }
}

private extension HTTPHeaderName {
    static let onTapDeviceIdentifier = HTTPHeaderName("x-device-identifier")
}
