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

    var testStatusRepository: TestStatusRepository!
    var testHistoryRepository: TestHistoryRepository!
    var testKarmaParser: TestKarmaParser!
    var testSlack: TestSlack!
    var testLogger: TestLogger!
    var testSecrets: Secrets!

    var controller: KarmaController!

    override func setUp() {
        app = try! Application.testable()

        testStatusRepository = TestStatusRepository()
        testHistoryRepository = TestHistoryRepository()
        testKarmaParser = TestKarmaParser()
        testSlack = TestSlack()
        testLogger = TestLogger()
        testSecrets = Secrets(slackAppBotUserAPI: "slackAppBotUserAPIKey", slackRequestSigningSecret: "slackRequestSigningSecret", onTapSecret: "onTapSecret")
        
        controller = KarmaController(karmaStatusRepository: testStatusRepository,
                                     karmaHistoryRepository: testHistoryRepository,
                                     karmaParser: testKarmaParser,
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

    // MARK: KarmaController+Slack
    func testThatItFailsACommandRequestWhenNoResponseUrl() {
        let command = commandWith(command: "/karma", response_url: nil)

        let request = emptyRequest(using: app)
        do {
            let status = try controller.command(request, content: command)
            XCTAssertEqual(status, .badRequest)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItFailsACommandRequestItCantValidate() {
        let command = commandWith(command: "/karma", response_url: "slackReponse")

        let request = emptyRequest(using: app)
        do {
            let status = try controller.command(request, content: command)
            XCTAssertEqual(status, .unauthorized)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItReturnsOkWhenCommandRequestIsValidated() {
        let command = commandWith(command: "/karma", response_url: "slackReponse")

        let request = validatedSlackRequest(using: app)
        do {
            let status = try controller.command(request, content: command)
            XCTAssertEqual(status, .ok)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItDoesNotAllowAUserToAdjustKarmaForSelf() {
        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")

        let expectedSlackMessage = SlackKitResponse(to: incomingMessage, text: "You can't adjust karma for yourself!")
        let expectedUser = "jacob"

        testSlack.sendMessageToUserHandler = { message, user in
            XCTAssertEqual(message as! SlackKitResponse, expectedSlackMessage)
            XCTAssertEqual(user, expectedUser)
        }

        testKarmaParser.karmaAdjustments = [KarmaAdjustment(user: "jacob", count: 3)]

        do {
            try controller.handle(incomingMessage: incomingMessage, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItHandlesWhenValidAdjustmentMessageWithNoExistingStatus() {
        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")

        let adjustment = KarmaAdjustment(user: "allen", count: -3)
        let status = KarmaStatus(id: "allen", count: -3, type: KarmaStatusType.user.rawValue)
        let expectedSlackMessage = KarmaStatusResponse(forKarmaAdjustingMessage: incomingMessage, receivedKarma: adjustment, statusAfterChange: status)

        testSlack.sendMessageHandler = { message in
            XCTAssertEqual(message as! KarmaStatusResponse, expectedSlackMessage)
        }
        testKarmaParser.karmaAdjustments = [adjustment]

        do {
            try controller.handle(incomingMessage: incomingMessage, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItHandlesWhenValidAdjustmentMessageWithExistingStatus() {
        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")

        let adjustment = KarmaAdjustment(user: "allen", count: 3)
        let originalStatus = KarmaStatus(id: "allen", count: -1, type: KarmaStatusType.user.rawValue)
        let changedStatus = KarmaStatus(id: "allen", count: 2, type: KarmaStatusType.user.rawValue)
        let expectedSlackMessage = KarmaStatusResponse(forKarmaAdjustingMessage: incomingMessage, receivedKarma: adjustment, statusAfterChange: changedStatus)

        testSlack.sendMessageHandler = { message in
            XCTAssertEqual(message as! KarmaStatusResponse, expectedSlackMessage)
        }
        testKarmaParser.karmaAdjustments = [adjustment]
        testStatusRepository.status = originalStatus

        do {
            try controller.handle(incomingMessage: incomingMessage, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItHandlesMultipleSlackResponsesFromMultipleAdjustmentMessages() {
        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")

        let allenAdjustment = KarmaAdjustment(user: "allen", count: 3)
        let ryanAdjustment = KarmaAdjustment(user: "ryan", count: 2)
        let allenStatus = KarmaStatus(id: "allen", count: 3, type: KarmaStatusType.user.rawValue)
        let ryanStatus = KarmaStatus(id: "ryan", count: 2, type: KarmaStatusType.user.rawValue)

        let expectedAllenMessage = KarmaStatusResponse(forKarmaAdjustingMessage: incomingMessage, receivedKarma: allenAdjustment, statusAfterChange: allenStatus)
        let expectedRyanMessage = KarmaStatusResponse(forKarmaAdjustingMessage: incomingMessage, receivedKarma: ryanAdjustment, statusAfterChange: ryanStatus)
        let expectedMessages = [expectedAllenMessage, expectedRyanMessage]

        testSlack.sendMessageHandler = { message in
            XCTAssertTrue(expectedMessages.contains(message as! KarmaStatusResponse))
        }
        testKarmaParser.karmaAdjustments = [allenAdjustment, ryanAdjustment]

        do {
            try controller.handle(incomingMessage: incomingMessage, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItSendsResponseWhenErrorOccurs() {
        let incomingMessage = SlackKitIncomingMessage(messageText: "text", channelId: "channelId", sender: "jacob", timestamp: "timestamp")

        let adjustment = KarmaAdjustment(user: "allen", count: 3)

        let expectedSlackMessage = SlackKitResponse(to: incomingMessage, text: "Something went wrong. Please try again")
        let expectedUser = "jacob"

        testSlack.sendMessageToUserHandler = { message, user in
            XCTAssertEqual(message as! SlackKitResponse, expectedSlackMessage)
            XCTAssertEqual(user, expectedUser)
        }
        testKarmaParser.karmaAdjustments = [adjustment]
        testStatusRepository.error = .badRepo

        do {
            try controller.handle(incomingMessage: incomingMessage, forBotUser: botUser())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

extension KarmaControllerTests {
    func commandWith(command: String?, response_url: String?) -> App.Command {
        return Command(command: command,
                       response_url: response_url,
                       trigger_id: nil,
                       text: nil,
                       team_id: nil,
                       team_domain: nil,
                       enterprise_id: nil,
                       enterprise_name: nil,
                       channel_id: nil,
                       channel_name: nil,
                       user_id: nil,
                       user_name: nil)
    }

    func botUser() -> User {
        return User(id: "xBot")
    }
}


