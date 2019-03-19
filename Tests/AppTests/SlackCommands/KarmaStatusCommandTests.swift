//
//  KarmaStatusCommandTests.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/18/19.
//

@testable import App
import struct SlackKit.User
import XCTest

final class KarmaStatusCommandTests: XCTestCase {
    private let timeout: Double = 2

    var testKarmaParser: TestKarmaParser!

    var responder: KarmaStatusResponder!

    override func setUp() {
        testKarmaParser = TestKarmaParser()

        responder = KarmaStatusResponder(karmaParser: testKarmaParser)
    }

    func testThatItCallsCompletionOnResponder() {
        let expectation = XCTestExpectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let expectedUserIds = ["jacob"]
        let expectedCommand = KarmaStatusCommand(incomingMessage: incomingMessage, userIds: expectedUserIds)

        testKarmaParser.statusMentionedUserId = "xBot"
        testKarmaParser.userIds = expectedUserIds

        let testCompletion: (KarmaStatusCommand, User) throws -> Void = { command, _ in
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

    func testThatItCallsCompletionOnResponderWhileFilteringOutAdditionalMentionedBotUser() {
        let expectation = XCTestExpectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let expectedUserIds = ["jacob", "allen"]
        let parsedUserIds = ["jacob", "xBot", "allen"]
        let expectedCommand = KarmaStatusCommand(incomingMessage: incomingMessage, userIds: expectedUserIds)

        testKarmaParser.statusMentionedUserId = "xBot"
        testKarmaParser.userIds = parsedUserIds

        let testCompletion: (KarmaStatusCommand, User) throws -> Void = { command, _ in
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

        let testCompletion: (KarmaStatusCommand, User) throws -> Void = { command, _ in
            XCTFail("Should not be getting called")
        }

        testKarmaParser.statusMentionedUserId = "xBot_not"

        XCTAssertTrue(responder.register(completion: testCompletion))
        do {
            try responder.handle(incomingMessage: incomingMessage, botUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItDoesNotCallCompletionBecauseParsedUserIdsIsEmpty() {
        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")

        let testCompletion: (KarmaStatusCommand, User) throws -> Void = { command, _ in
            XCTFail("Should not be getting called")
        }

        testKarmaParser.statusMentionedUserId = "xBot"

        XCTAssertTrue(responder.register(completion: testCompletion))
        do {
            try responder.handle(incomingMessage: incomingMessage, botUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItDoesNotCallCompletionBecauseParsedUserIdsContainsBotUserAndThenIsEmpty() {
        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")

        let parsedUserIds = ["xBot"]

        let testCompletion: (KarmaStatusCommand, User) throws -> Void = { command, _ in
            XCTFail("Should not be getting called")
        }

        testKarmaParser.statusMentionedUserId = "xBot"
        testKarmaParser.userIds = parsedUserIds

        XCTAssertTrue(responder.register(completion: testCompletion))
        do {
            try responder.handle(incomingMessage: incomingMessage, botUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

extension KarmaStatusCommandTests {
    func botUser() -> User {
        return User(id: "xBot")
    }
}
