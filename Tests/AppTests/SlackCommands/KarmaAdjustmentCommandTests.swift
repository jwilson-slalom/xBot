//
//  KarmaAdjustmentCommandTests.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/18/19.
//

@testable import App
import struct SlackKit.User
import XCTest

final class KarmaAdjustmentCommandTests: XCTestCase {
    private let timeout: Double = 2

    var testKarmaParser: TestKarmaParser!

    var responder: KarmaAdjustmentResponder!

    override func setUp() {
        testKarmaParser = TestKarmaParser()

        responder = KarmaAdjustmentResponder(karmaParser: testKarmaParser)
    }

    func testThatItCallsCompletionOnResponder() {
        let expectation = XCTestExpectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let expectedAdjustments = [KarmaAdjustment(user: "allen", count: 1)]
        let expectedCommand = KarmaAdjustmentCommand(incomingMessage: incomingMessage, adjustments: expectedAdjustments)

        testKarmaParser.karmaAdjustments = expectedAdjustments

        let testCompletion: (KarmaAdjustmentCommand, User) throws -> Void = { command, _ in
            XCTAssertEqual(command, expectedCommand)

            expectation.fulfill()
        }

        XCTAssertTrue(responder.register(completion: testCompletion))
        do {
            try responder.handle(incomingMessage: incomingMessage, botUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        wait(for: [expectation], timeout: timeout)
    }

    func testThatItDoesNotCallCompletionOnResponderWhenBadCompletionIsSentIn() {
        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")

        let testCompletion: (KarmaStatusCommand, User) throws -> Void = { command, _ in
            XCTFail("Should not be getting called")
        }

        XCTAssertFalse(responder.register(completion: testCompletion))
        do {
            try responder.handle(incomingMessage: incomingMessage, botUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItDoesNotCallCompletionOnResponderWhenCantParseCommand() {
        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")

        let testCompletion: (KarmaAdjustmentCommand, User) throws -> Void = { command, _ in
            XCTFail("Should not be getting called")
        }

        XCTAssertTrue(responder.register(completion: testCompletion))
        do {
            try responder.handle(incomingMessage: incomingMessage, botUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

extension KarmaAdjustmentCommandTests {
    func botUser() -> User {
        return User(id: "xBot")
    }
}
