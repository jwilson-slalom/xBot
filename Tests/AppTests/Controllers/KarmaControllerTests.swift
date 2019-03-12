//
//  KarmaControllerTests.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/12/19.
//

@testable import App
import XCTest

final class KarmaControllerTests: AppTestCase {

    var testStatusRepository: TestStatusRepository!
    var testHistoryRepository: TestHistoryRepository!
    var testSlack: TestSlack!
    var testLogger: TestLogger!
    var testSecrets: Secrets!

    var controller: KarmaController!

    override func setUp() {
        super.setUp()

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
        super.tearDown()

        try? testStatusRepository.shutdown()
    }

    func testThatItReturnsAllStatusObjects() {
        let expectedStatuses = [KarmaStatus(id: "StatusId", count: 2, type: .user),
                                KarmaStatus(id: "OtherId", count: 3, type: .other)]
        testStatusRepository.statuses = expectedStatuses

        let request = emptyRequest()
        do {
            let statuses = try controller.allStatus(request).wait()
            XCTAssertEqual(statuses, expectedStatuses)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItCreatesAStatus() {
        let expectedStatus = KarmaStatus(id: "StatusId", count: 2, type: .user)

        let request = emptyRequest()
        do {
            let status = try controller.createStatus(request, content: expectedStatus).wait()
            XCTAssertEqual(status, expectedStatus)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatItUpdatesAStatus() {
        let expectedStatus = KarmaStatus(id: "StatusId", count: 2, type: .user)

        let request = emptyRequest()
        do {
            let status = try controller.updateStatus(request, content: expectedStatus).wait()
            XCTAssertEqual(status, expectedStatus)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
