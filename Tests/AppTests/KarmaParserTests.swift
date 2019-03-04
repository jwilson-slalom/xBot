//
//  KarmaParserTests.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/4/19.
//

@testable import App
import XCTest

final class KarmaParserTests: XCTestCase {
    static let allTests = [
        ("testThatItParsesOneUser_Positive", testThatItParsesOneUser_Positive),
        ("testThatItParsesOneUser_Negative", testThatItParsesOneUser_Negative),
        ("testThatItParsesMultipleUser_Positive", testThatItParsesMultipleUser_Positive),
        ("testThatItParsesMultipleUser_Negative", testThatItParsesMultipleUser_Negative),
        ("testThatItDoesNotParsesUsers_Positive", testThatItDoesNotParsesUsers_Positive),
        ("testThatItDoesNotParsesUsers_Negative", testThatItDoesNotParsesUsers_Negative),
        ("testThatItDoesParsesUsersAndHitsMaximum_Positive", testThatItDoesParsesUsersAndHitsMaximum_Positive),
        ("testThatItDoesParsesUsersAndHitsMaximum_Negative", testThatItDoesParsesUsersAndHitsMaximum_Negative)
    ]

    var testMessage: String!
    var expectedKarmaMessages: [KarmaMessage]!

    var parser: KarmaParser!

    override func setUp() {
        parser = KarmaParser()
    }

    func testThatItParsesOneUser_Positive() {
        expectedKarmaMessages = [KarmaMessage(user: "Jacob", karma: 1)]

        testMessage = "<@Jacob>++"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "<@Jacob> ++"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "   <@Jacob>  ++"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)
    }

    func testThatItParsesOneUser_Negative() {
        expectedKarmaMessages = [KarmaMessage(user: "Jacob", karma: -1)]

        testMessage = "<@Jacob>--"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "<@Jacob> --"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = " asdfa <@Jacob> --"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)
    }

    func testThatItParsesMultipleUser_Positive() {
        expectedKarmaMessages = [KarmaMessage(user: "Jacob", karma: 2),
                                 KarmaMessage(user: "Allen", karma: 2)]

        testMessage = "<@Jacob> <@Allen>+++"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "<@Jacob> <@Allen> +++"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = " sadfa <@Jacob> <@Allen>   +++"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        expectedKarmaMessages = [KarmaMessage(user: "Ryan", karma: 2),
                                 KarmaMessage(user: "Jacob", karma: 2),
                                 KarmaMessage(user: "Allen", karma: 2)]

        testMessage = "<@Ryan> apples <@Jacob> <@Allen> +++"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "<@Ryan> <@Jacob> <@Allen>+++"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)
    }

    func testThatItParsesMultipleUser_Negative() {
        expectedKarmaMessages = [KarmaMessage(user: "Jacob", karma: -2),
                                 KarmaMessage(user: "Allen", karma: -2)]

        testMessage = "<@Jacob> <@Allen>---"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "<@Jacob> <@Allen> ---"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = " sadfa <@Jacob> <@Allen>   ---"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        expectedKarmaMessages = [KarmaMessage(user: "Ryan", karma: -2),
                                 KarmaMessage(user: "Jacob", karma: -2),
                                 KarmaMessage(user: "Allen", karma: -2)]

        testMessage = "<@Ryan> apples <@Jacob> <@Allen> ---"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "<@Ryan> <@Jacob> <@Allen> ---"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        expectedKarmaMessages = [KarmaMessage(user: "Jacob", karma: -2),
                                 KarmaMessage(user: "Allen", karma: -2)]
        testMessage = "<@R yan> <@Jacob> <@Allen> ---"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)
    }

    func testThatItDoesNotParsesUsers_Positive() {
        expectedKarmaMessages = [KarmaMessage]()

        testMessage = "<@Jacob> <@Allen> asdasd +++"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = " sadfaa +++"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "+++"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "test message "
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "<@Ryan>"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)
    }

    func testThatItDoesNotParsesUsers_Negative() {
        expectedKarmaMessages = [KarmaMessage]()

        testMessage = "<@Jacob> <@Allen> asdasd --"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = " sadfaa --"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "----"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "test message "
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "<@Ryan>"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)
    }

    func testThatItDoesParsesUsersAndHitsMaximum_Positive() {
        expectedKarmaMessages = [KarmaMessage(user: "Jacob", karma: 5)]

        testMessage = "<@Jacob> +++++++++++++++"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "<@Jacob>++++++"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)
    }

    func testThatItDoesParsesUsersAndHitsMaximum_Negative() {
        expectedKarmaMessages = [KarmaMessage(user: "Jacob", karma: -5)]

        testMessage = "<@Jacob> ---------------"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)

        testMessage = "<@Jacob>------"
        compareKarmaMessages(actual: parser.karmaMessages(from: testMessage), expected: expectedKarmaMessages)
    }

    private func compareKarmaMessages(actual: [KarmaMessage], expected: [KarmaMessage]) {
        for (index, karmaMessage) in actual.enumerated() {
            XCTAssertEqual(karmaMessage, expected[index])
        }
    }
}
