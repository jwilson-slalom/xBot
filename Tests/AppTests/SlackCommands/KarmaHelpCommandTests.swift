//
//  KarmaHelpCommandTests.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/21/19.
//

@testable import App
import struct SlackKit.User
import XCTest

final class KarmaHelpCommandTests: XCTestCase {
    private let timeout: Double = 2

    var testKarmaParser: TestKarmaParser!

    var responder: KarmaHelpResponder!

    override func setUp() {
        testKarmaParser = TestKarmaParser()

        responder = KarmaHelpResponder(isRelease: false, karmaParser: testKarmaParser)
    }

    func testThatItCallsCompletionOnResponder() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let helpMessage = "For more information about xBot and how to interact with me, visit this <http://localhost:8080/help|help site>"
        let expectedCommand = KarmaHelpCommand(incomingMessage: incomingMessage, helpMessage: helpMessage)

        testKarmaParser.helpMentionedUserId = "xBot"

        let testCompletion: (KarmaHelpCommand, User) throws -> Void = { command, _ in
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

    func testThatItCallsCompletionOnResponderAndLinkIsCorrectForProduction() {
        let expectation = self.expectation(description: #function)

        responder = KarmaHelpResponder(isRelease: true, karmaParser: testKarmaParser)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let helpMessage = "For more information about xBot and how to interact with me, visit this <https://slalom-build-xbot.herokuapp.com/help|help site>"
        let expectedCommand = KarmaHelpCommand(incomingMessage: incomingMessage, helpMessage: helpMessage)

        testKarmaParser.helpMentionedUserId = "xBot"

        let testCompletion: (KarmaHelpCommand, User) throws -> Void = { command, _ in
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

        let testCompletion: (KarmaHelpCommand, User) throws -> Void = { command, _ in
            XCTFail("Should not be getting called")
        }

        testKarmaParser.helpMentionedUserId = "xBot_not"

        XCTAssertTrue(responder.register(completion: testCompletion))
        do {
            try responder.handle(incomingMessage: incomingMessage, botUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

extension KarmaHelpCommandTests {
    func botUser() -> User {
        return User(id: "xBot")
    }
}
