//
//  KarmaLeaderboardCommandTests.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/19/19.
//

@testable import App
import struct SlackKit.User
import XCTest

final class KarmaLeaderboardCommandTests: XCTestCase {
    private let timeout: Double = 2

    var testKarmaParser: TestKarmaParser!

    var responder: KarmaLeaderboardResponder!

    override func setUp() {
        testKarmaParser = TestKarmaParser()

        responder = KarmaLeaderboardResponder(karmaParser: testKarmaParser)
    }

    func testThatItCallsCompletionOnResponder() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let expectedCommand = KarmaLeaderboardCommand(incomingMessage: incomingMessage)

        testKarmaParser.leaderboardMentionedUserId = "xBot"

        let testCompletion: (KarmaLeaderboardCommand, User) throws -> Void = { command, _ in
            XCTAssertEqual(command, expectedCommand)

            expectation.fulfill()
        }

        XCTAssertTrue(responder.register(completion: testCompletion))
        do {
            try responder.handle(incomingMessage: incomingMessage, botUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    func testThatItDoesNotCallCompletionOnResponderWhenBadCompletionIsSentIn() {
        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")

        let testCompletion: (KarmaAdjustmentCommand, User) throws -> Void = { command, _ in
            XCTFail("Should not be getting called")
        }

        XCTAssertFalse(responder.register(completion: testCompletion))
        do {
            try responder.handle(incomingMessage: incomingMessage, botUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItDoesNotCallCompletionBecauseMentionedIdDoesNotEqualBotUser() {
        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")

        let testCompletion: (KarmaLeaderboardCommand, User) throws -> Void = { command, _ in
            XCTFail("Should not be getting called")
        }

        testKarmaParser.leaderboardMentionedUserId = "xBot_not"

        XCTAssertTrue(responder.register(completion: testCompletion))
        do {
            try responder.handle(incomingMessage: incomingMessage, botUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

extension KarmaLeaderboardCommandTests {
    func botUser() -> User {
        return User(id: "xBot")
    }
}
