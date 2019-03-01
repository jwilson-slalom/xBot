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
import struct SlackKit.Attachment

struct OnTapMessage {

    static func newBeerAttachment(for tap: Tap, with beer: Beer) -> Attachment {

        return Attachment(attachment: ["fallback": "New beer",
                                       "color": "#36a64f",
                                       "title": "\(beer.name) is now on the \(tap == .left ? "Left" : "Right") Tap 🍻",
                                       "title_link": beer.untappdURL.absoluteString,
                                       "fields": [
                                            "value": beer.breweryName,
                                            "short": false
                                            ],
                                       "footer": "Brought to you by: _onTap"
                                        ]
                        )
    }

    static func kegStatusAttachments(with kegSystem: KegSystem) -> [Attachment] {

        func beerText(_ beer: Beer?) -> String? {
            guard let beer = beer else { return nil }

            return beer.name + " - " + beer.breweryName
        }
        return
            [Attachment(attachment:
                [
                    "fallback": "Required plain-text summary of the attachment.",
                    "color": "#36a64f",
                    "pretext": "🍻",
                    "title": leftBeer == nil ? "Offline" : "Left Tap",
                    "title_link": kegSystem.leftTap?.untappdURL.absoluteString as Any,
                    "text": beerText(kegSystem.leftTap) as Any
                ]),
             Attachment(attachment:
                [
                    "fallback": "Required plain-text summary of the attachment.",
                    "color": "#36a64f",
                    "title": leftBeer == nil ? "Offline" : "Right Tap",
                    "title_link": kegSystem.rightTap?.untappdURL.absoluteString as Any,
                    "text": beerText(kegSystem.rightTap) as Any
                ])
        ]
    }
}

struct KegSystem: Content {
    var leftTap: Beer?
    var rightTap: Beer?
}

// Absolutely not threadsafe
fileprivate var leftBeerChangeCount: Int64 = -1
fileprivate var leftBeer: Beer?

fileprivate var rightBeerChangeCount: Int64 = -1
fileprivate var rightBeer: Beer?

func set(beer newBeer: Beer?, on tap: Tap) -> Bool {
    var oldValue: Beer?
    switch tap {
    case .left:
        oldValue = leftBeer
        leftBeer = newBeer
    case .right:
        oldValue = rightBeer
        rightBeer = newBeer
    }

    func different(_ oldBeer: Beer?, _ newBeer: Beer?) -> Bool {
        switch (oldValue, newBeer) {
        case let (old?, new?) where old.untappdID != new.untappdID:
            fallthrough
        case (.none, _), (_, .none):
            return true
        default:
            return false
        }
    }

    // Ignores the initial set after the server starts

    if different(oldValue, newBeer) {
        switch tap {
        case .left:
            leftBeerChangeCount += 1
            if leftBeerChangeCount > 0 {
                return true
            }
        case .right:
            rightBeerChangeCount += 1
            if rightBeerChangeCount > 0 {
                return true
            }
        }
    }

    return false
}

final class OnTapController: RouteCollection, ServiceType {

    let slackKitService: SlackKitService

    init(slackKitService: SlackKitService) {
        self.slackKitService = slackKitService
    }

    static func makeService(for container: Container) throws -> OnTapController {
        return OnTapController(slackKitService: App.slackKitService)
    }

    func boot(router: Router) throws {
        let onTapGroup = router.grouped("/ontap")
        onTapGroup.post(Beer.self, at: "/tap", Tap.parameter, use: update)
        onTapGroup.delete("/tap", Tap.parameter, use: delete)
        onTapGroup.get("/taps", use: getBeers)
    }

    func getBeers(request: Request) -> KegSystem {
        return KegSystem(leftTap: leftBeer, rightTap: rightBeer)
    }

    func update(request: Request, content: Beer) -> EventLoopFuture<Response> {
        guard let deviceID = request.http.headers.firstValue(name: .onTapDeviceIdentifier),
                deviceID == "21F17F00-A94B-4BE9-A03D-BA6A20D709FC" else {

            return request.response().encode(status: .unauthorized, for: request)
        }

        do {
            let tap = try request.parameters.next(Tap.self)

            print("Received \(content) for tap \(tap)")

            if set(beer: content, on: tap) {
                print("Tap \(tap) changed to: \(content)")

                try slackKitService.sendMessage(
                    text: "",
                    channelId: waterCoolerChannelID,
                    attachments: [OnTapMessage.newBeerAttachment(for: tap, with: content)]
                )
            }

            // TODO: Update slack if the beers changed
            return KegSystem(leftTap: leftBeer, rightTap: rightBeer).encode(status: .ok, for: request)
        } catch let error as RoutingError {
            return error.description.encode(status: .badRequest, for: request)
        } catch {
            return request.response().encode(status: .internalServerError, for: request)
        }
    }

    func delete(request: Request) -> EventLoopFuture<Response> {
        guard let deviceID = request.http.headers.firstValue(name: .onTapDeviceIdentifier),
                deviceID == "21F17F00-A94B-4BE9-A03D-BA6A20D709FC" else {

            return request.response().encode(status: .unauthorized, for: request)
        }

        do {

            let tap = try request.parameters.next(Tap.self)
            if set(beer: nil, on: tap) {
                print("Tap \(tap) changed to: \(Optional<Beer>.none)")
            }

            return KegSystem(leftTap: leftBeer, rightTap: rightBeer).encode(status: .ok, for: request)

        } catch let error as RoutingError {
            return error.description.encode(status: .badRequest, for: request)
        } catch {
            return request.response().encode(status: .internalServerError, for: request)
        }
    }
}

extension HTTPHeaderName {
    static let onTapDeviceIdentifier = HTTPHeaderName("x-device-identifier")
}

let waterCoolerChannelID = "CGL7CJ03W"

extension OnTapController: SlackHandler {

    var eventTypes: [EventType] { return [.message] }

    func handleEvent(event: Event, slack: SlackMessageSender) {

        if event.message?.text?.contains("beer") ?? false {

            do {
                try slack.sendMessage(
                    text: "",
                    channelId: event.channel!.id!,
                    attachments: OnTapMessage.kegStatusAttachments(with: KegSystem(leftTap: leftBeer, rightTap: rightBeer))
                )
            } catch {
                print("Failed to send slack message: \(error)")
            }
        }
    }
}
