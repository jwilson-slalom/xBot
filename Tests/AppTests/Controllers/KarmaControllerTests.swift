//
//  KarmaControllerTests.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/12/19.
//

@testable import App
import Vapor
import struct SlackKit.User
import XCTest

final class KarmaControllerTests: XCTestCase {
    var app: Application!

    let timeout: Double = 2

    var testStatusRepository: TestStatusRepository!
    var testHistoryRepository: TestHistoryRepository!
    var testSlack: TestSlack!
    var testLogger: TestLogger!
    var testSecrets: Secrets!

    var controller: KarmaController!

    override func setUp() {
        app = try! Application.testable()

        testStatusRepository = TestStatusRepository()
        testHistoryRepository = TestHistoryRepository()
        testSlack = TestSlack()
        testLogger = TestLogger()
        testSecrets = Secrets(slackAppBotUserAPI: "slackAppBotUserAPIKey", slackRequestSigningSecret: "slackRequestSigningSecret", onTapSecret: "onTapSecret")
        
        controller = KarmaController(karmaStatusRepository: testStatusRepository,
                                     karmaHistoryRepository: testHistoryRepository,
                                     slack: testSlack,
                                     log: testLogger,
                                     secrets: testSecrets)
    }

    override func tearDown() {
        try? app.syncShutdownGracefully()

        try? testStatusRepository.shutdown()
        try? testHistoryRepository.shutdown()
    }

    // MARK: KarmaController+Status
    func testThatItReturnsAllStatusObjects() {
        let expectedStatuses = [KarmaStatus(id: "StatusId", count: 2, type: KarmaStatusType.user.rawValue),
                                KarmaStatus(id: "OtherId", count: 3, type: KarmaStatusType.other.rawValue)]
        testStatusRepository.statuses = expectedStatuses

        let request = emptyRequest(using: app)
        do {
            let statuses = try controller.allStatus(request).wait()
            XCTAssertEqual(statuses, expectedStatuses)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItCreatesAStatus() {
        let expectedStatus = KarmaStatus(id: "StatusId", count: 2, type: KarmaStatusType.user.rawValue)

        let request = emptyRequest(using: app)
        do {
            let status = try controller.createStatus(request, content: expectedStatus).wait()
            XCTAssertEqual(status, expectedStatus)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItUpdatesAStatus() {
        let expectedStatus = KarmaStatus(id: "StatusId", count: 2, type: KarmaStatusType.user.rawValue)

        let request = emptyRequest(using: app)
        do {
            let status = try controller.updateStatus(request, content: expectedStatus).wait()
            XCTAssertEqual(status, expectedStatus)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    // MARK: KarmaController+History
    func testThatItReturnsAllHistoryObjects() {
        let expectedHistory = [KarmaSlackHistory(id: 1, karmaCount: 2, karmaReceiver: "allen", karmaSender: "jacob", inChannel: "watercooler"),
                               KarmaSlackHistory(id: 2, karmaCount: 1, karmaReceiver: "jacob", karmaSender: "allen", inChannel: "watercooler")]
        testHistoryRepository.multiHistory = expectedHistory

        let request = emptyRequest(using: app)
        do {
            let history = try controller.allHistory(request).wait()
            XCTAssertEqual(history, expectedHistory)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItCreatesAHistory() {
        let expectedHistory = KarmaSlackHistory(id: 1, karmaCount: 2, karmaReceiver: "allen", karmaSender: "jacob", inChannel: "watercooler")

        let request = emptyRequest(using: app)
        do {
            let history = try controller.createHistory(request, content: expectedHistory).wait()
            XCTAssertEqual(history, expectedHistory)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    // MARK: KarmaController+KarmaAdjustmentCommand Handling
    func testThatItDoesNotAllowAUserToAdjustKarmaForSelf() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let adjustments = [KarmaAdjustment(user: "jacob", count: 3)]
        let command = KarmaAdjustmentCommand(incomingMessage: incomingMessage, adjustments: adjustments)

        let expectedSlackMessage = SlackKitResponse(to: incomingMessage, text: "You can't adjust karma for yourself!")
        let expectedUser = "jacob"

        testSlack.sendMessageToUserHandler = { message, user in
            XCTAssertEqual(message as! SlackKitResponse, expectedSlackMessage)
            XCTAssertEqual(user, expectedUser)

            expectation.fulfill()
        }

        do {
            try controller.handleKarmaAdjustmentCommand(command, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    func testThatItHandlesWhenValidAdjustmentMessageWithNoExistingStatus() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let adjustment = KarmaAdjustment(user: "allen", count: -3)
        let adjustments = [adjustment]
        let command = KarmaAdjustmentCommand(incomingMessage: incomingMessage, adjustments: adjustments)

        let status = KarmaStatus(id: "allen", count: -3, type: KarmaStatusType.user.rawValue)
        let expectedSlackMessage = KarmaStatusResponse(forKarmaAdjustingMessage: incomingMessage, receivedKarma: adjustment, statusAfterChange: status)

        testSlack.sendMessageHandler = { message in
            XCTAssertEqual(message as! KarmaStatusResponse, expectedSlackMessage)

            expectation.fulfill()
        }

        do {
            try controller.handleKarmaAdjustmentCommand(command, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    func testThatItHandlesWhenValidAdjustmentMessageWithExistingStatus() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let adjustment = KarmaAdjustment(user: "allen", count: 3)
        let adjustments = [adjustment]
        let command = KarmaAdjustmentCommand(incomingMessage: incomingMessage, adjustments: adjustments)

        let originalStatus = KarmaStatus(id: "allen", count: -1, type: KarmaStatusType.user.rawValue)
        let changedStatus = KarmaStatus(id: "allen", count: 2, type: KarmaStatusType.user.rawValue)
        let expectedSlackMessage = KarmaStatusResponse(forKarmaAdjustingMessage: incomingMessage, receivedKarma: adjustment, statusAfterChange: changedStatus)

        testSlack.sendMessageHandler = { message in
            XCTAssertEqual(message as! KarmaStatusResponse, expectedSlackMessage)

            expectation.fulfill()
        }
        testStatusRepository.status = originalStatus

        do {
            try controller.handleKarmaAdjustmentCommand(command, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    func testThatItHandlesMultipleSlackResponsesFromMultipleAdjustmentMessages() {
        let expectation1 = self.expectation(description: #function + "1")
        let expectation2 = self.expectation(description: #function + "2")

        // TODO: Can not use this. Does not compile on Linux
        //expectation.expectedFulfillmentCount = 2

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let allenAdjustment = KarmaAdjustment(user: "allen", count: 3)
        let ryanAdjustment = KarmaAdjustment(user: "ryan", count: 2)
        let adjustments = [allenAdjustment, ryanAdjustment]
        let command = KarmaAdjustmentCommand(incomingMessage: incomingMessage, adjustments: adjustments)

        let allenStatus = KarmaStatus(id: "allen", count: 3, type: KarmaStatusType.user.rawValue)
        let ryanStatus = KarmaStatus(id: "ryan", count: 2, type: KarmaStatusType.user.rawValue)

        let expectedAllenMessage = KarmaStatusResponse(forKarmaAdjustingMessage: incomingMessage, receivedKarma: allenAdjustment, statusAfterChange: allenStatus)
        let expectedRyanMessage = KarmaStatusResponse(forKarmaAdjustingMessage: incomingMessage, receivedKarma: ryanAdjustment, statusAfterChange: ryanStatus)
        let expectedMessages = [expectedAllenMessage, expectedRyanMessage]


        var sendMessageCount = 0
        testSlack.sendMessageHandler = { message in
            sendMessageCount += 1
            if sendMessageCount == 1 {
                XCTAssertTrue(expectedMessages.contains(message as! KarmaStatusResponse))
                expectation1.fulfill()
            } else if sendMessageCount == 2 {
                XCTAssertTrue(expectedMessages.contains(message as! KarmaStatusResponse))
                expectation2.fulfill()
            }
        }

        do {
            try controller.handleKarmaAdjustmentCommand(command, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    func testThatItSendsResponseWhenErrorOccurs() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let adjustment = KarmaAdjustment(user: "allen", count: 3)
        let adjustments = [adjustment]
        let command = KarmaAdjustmentCommand(incomingMessage: incomingMessage, adjustments: adjustments)

        let expectedSlackMessage = SlackKitResponse(to: incomingMessage, text: "Something went wrong. Please try again")
        let expectedUser = "jacob"

        testSlack.sendMessageToUserHandler = { message, user in
            XCTAssertEqual(message as! SlackKitResponse, expectedSlackMessage)
            XCTAssertEqual(user, expectedUser)

            expectation.fulfill()
        }
        testStatusRepository.error = .badRepo

        do {
            try controller.handleKarmaAdjustmentCommand(command, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    // MARK: KarmaController+KarmaStatusCommand Handling
    func testThatItSendsSlackMessageFromValidStatusCommand() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let userIds = ["jacob"]
        let command = KarmaStatusCommand(incomingMessage: incomingMessage, userIds: userIds)

        let statuses = [KarmaStatus(id: "allen", count: 2, type: KarmaStatusType.user.rawValue)]
        let expectedSlackMessage = KarmaStatusResponse(forKarmaStatusMessage: incomingMessage, statuses: statuses)

        testSlack.sendMessageHandler = { message in
            XCTAssertEqual(message as! KarmaStatusResponse, expectedSlackMessage)

            expectation.fulfill()
        }
        testStatusRepository.statuses = statuses

        do {
            try controller.handleKarmaStatusCommand(command, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    func testThatItSendsOneSlackMessageFromValidStatusCommandWithMultipleStatus() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let userIds = ["jacob"]
        let command = KarmaStatusCommand(incomingMessage: incomingMessage, userIds: userIds)

        let statuses = [KarmaStatus(id: "allen", count: 2, type: KarmaStatusType.user.rawValue),
                        KarmaStatus(id: "jimmy", count: -3, type: KarmaStatusType.user.rawValue)]
        let expectedSlackMessage = KarmaStatusResponse(forKarmaStatusMessage: incomingMessage, statuses: statuses)

        testSlack.sendMessageHandler = { message in
            XCTAssertEqual(message as! KarmaStatusResponse, expectedSlackMessage)

            expectation.fulfill()
        }
        testStatusRepository.statuses = statuses

        do {
            try controller.handleKarmaStatusCommand(command, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    func testThatItSendsSlackMessageFromValidStatusCommandButEmptyStatusesReturned() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let userIds = ["jacob"]
        let command = KarmaStatusCommand(incomingMessage: incomingMessage, userIds: userIds)

        let expectedSlackMessage = SlackKitResponse(to: incomingMessage, text: "Couldn't find any karma!")

        testSlack.sendMessageHandler = { message in
            XCTAssertEqual(message as! SlackKitResponse, expectedSlackMessage)

            expectation.fulfill()
        }
        testStatusRepository.statuses = [KarmaStatus]()

        do {
            try controller.handleKarmaStatusCommand(command, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    func testThatItSendsSlackMessageFromValidStatusCommandBadFutureReturned() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let userIds = ["jacob"]
        let command = KarmaStatusCommand(incomingMessage: incomingMessage, userIds: userIds)

        let expectedSlackMessage = SlackKitResponse(to: incomingMessage, text: "Something went wrong. Please try again")

        testSlack.sendMessageHandler = { message in
            XCTAssertEqual(message as! SlackKitResponse, expectedSlackMessage)

            expectation.fulfill()
        }

        do {
            try controller.handleKarmaStatusCommand(command, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    // MARK: KarmaController+KarmaLeaderboardCommand Handling
    func testThatItSendsSlackMessageFromValidLeaderboardCommand() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let command = KarmaLeaderboardCommand(incomingMessage: incomingMessage)

        let statuses = [KarmaStatus(id: "allen", count: 2, type: KarmaStatusType.user.rawValue)]
        let expectedSlackMessage = KarmaStatusResponse(forKarmaLeaderboardMessage: incomingMessage, statuses: statuses)

        testSlack.sendMessageHandler = { message in
            XCTAssertEqual(message as! KarmaStatusResponse, expectedSlackMessage)

            expectation.fulfill()
        }
        testStatusRepository.statuses = statuses

        do {
            try controller.handleKarmaLeaderboardCommand(command, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    func testThatItSendsOneSlackMessageFromValidLeaderboardCommandWithMultipleStatus() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let command = KarmaLeaderboardCommand(incomingMessage: incomingMessage)

        let statuses = [KarmaStatus(id: "allen", count: 2, type: KarmaStatusType.user.rawValue),
                        KarmaStatus(id: "jimmy", count: -3, type: KarmaStatusType.user.rawValue)]
        let expectedSlackMessage = KarmaStatusResponse(forKarmaLeaderboardMessage: incomingMessage, statuses: statuses)

        testSlack.sendMessageHandler = { message in
            XCTAssertEqual(message as! KarmaStatusResponse, expectedSlackMessage)

            expectation.fulfill()
        }
        testStatusRepository.statuses = statuses

        do {
            try controller.handleKarmaLeaderboardCommand(command, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    func testThatItSendsSlackMessageFromValidLeaderboardCommandButEmptyStatusesReturned() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let command = KarmaLeaderboardCommand(incomingMessage: incomingMessage)

        let expectedSlackMessage = SlackKitResponse(to: incomingMessage, text: "Couldn't find any karma!")

        testSlack.sendMessageHandler = { message in
            XCTAssertEqual(message as! SlackKitResponse, expectedSlackMessage)

            expectation.fulfill()
        }
        testStatusRepository.statuses = [KarmaStatus]()

        do {
            try controller.handleKarmaLeaderboardCommand(command, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    func testThatItSendsSlackMessageFromValidLeaderboardCommandBadFutureReturned() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let command = KarmaLeaderboardCommand(incomingMessage: incomingMessage)

        let expectedSlackMessage = SlackKitResponse(to: incomingMessage, text: "Something went wrong. Please try again")

        testSlack.sendMessageHandler = { message in
            XCTAssertEqual(message as! SlackKitResponse, expectedSlackMessage)

            expectation.fulfill()
        }

        do {
            try controller.handleKarmaLeaderboardCommand(command, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    // MARK: KarmaController+KarmaHelpCommand Handling
    func testThatItSendsSlackMessageFromValidHelpCommand() {
        let expectation = self.expectation(description: #function)

        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")
        let helpMessage = "Help Message"
        let command = KarmaHelpCommand(incomingMessage: incomingMessage, helpMessage: helpMessage)

        let expectedSlackMessage = SlackHelpResponse(from: command)

        testSlack.sendMessageHandler = { message in
            XCTAssertEqual(message as! SlackHelpResponse, expectedSlackMessage)

            expectation.fulfill()
        }

        do {
            try controller.handleKarmaHelpCommand(command, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }
}

extension KarmaControllerTests {
    func botUser() -> User {
        return User(id: "xBot")
    }
}


