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
        ("testThatItParsesMultipleUser_PositiveAndNegative", testThatItParsesMultipleUser_PositiveAndNegative),
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
        expectedKarmaMessages = [KarmaMessage(user: "U12345678", karma: 1)]

        testMessage = "<@U12345678|jacob>++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "<@U12345678> ++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "   <@U12345678>  ++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)
    }

    func testThatItParsesOneUser_Negative() {
        expectedKarmaMessages = [KarmaMessage(user: "U12345678", karma: -1)]

        testMessage = "<@U12345678|jacob>--"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "<@U12345678> --"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = " asdfa <@U12345678> --"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)
    }

    func testThatItParsesMultipleUser_Positive() {
        expectedKarmaMessages = [KarmaMessage(user: "U12345678", karma: 2),
                                 KarmaMessage(user: "U98765432", karma: 2)]

        testMessage = "<@U12345678>+++ <@U98765432>+++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "<@U12345678|jacob> +++ <@U98765432> +++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = " sadfa <@U12345678>+++ <@U98765432|allen>   +++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        expectedKarmaMessages = [KarmaMessage(user: "URY13AN12", karma: 1),
                                 KarmaMessage(user: "U12345678", karma: 3),
                                 KarmaMessage(user: "U98765432", karma: 2)]

        testMessage = "<@URY13AN12>++ apples <@U12345678>++++ <@U98765432> +++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "<@URY13AN12>++   asdf    <@U12345678>   ++++ <@U98765432> +++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)
    }

    func testThatItParsesMultipleUser_Negative() {
        expectedKarmaMessages = [KarmaMessage(user: "U12345678", karma: -2),
                                 KarmaMessage(user: "U98765432", karma: -2)]

        testMessage = "<@U12345678>--- <@U98765432>---"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "<@U12345678|jacob> --- <@U98765432> ---"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = " sadfa <@U12345678>--- <@U98765432|allen>   ---"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        expectedKarmaMessages = [KarmaMessage(user: "URY13AN12", karma: -1),
                                 KarmaMessage(user: "U12345678", karma: -3),
                                 KarmaMessage(user: "U98765432", karma: -2)]

        testMessage = "<@URY13AN12>-- apples <@U12345678>---- <@U98765432> ---"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "<@URY13AN12>--   asdf    <@U12345678>   ---- <@U98765432> ---"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)
    }

    func testThatItParsesMultipleUser_PositiveAndNegative() {
        expectedKarmaMessages = [KarmaMessage(user: "U12345678", karma: -2),
                                 KarmaMessage(user: "U98765432", karma: 2)]

        testMessage = "<@U12345678>--- <@U98765432>+++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "<@U12345678|jacob> --- <@U98765432> +++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = " sadfa <@U12345678>--- <@U98765432|allen>   +++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        expectedKarmaMessages = [KarmaMessage(user: "URY13AN12", karma: 1),
                                 KarmaMessage(user: "U12345678", karma: -3),
                                 KarmaMessage(user: "U98765432", karma: 2)]

        testMessage = "<@URY13AN12>++ apples <@U12345678>---- <@U98765432> +++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "<@URY13AN12>++   asdf    <@U12345678>   ---- <@U98765432> +++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)
    }

    func testThatItDoesNotParsesUsers_Positive() {
        expectedKarmaMessages = [KarmaMessage]()

        testMessage = "<@U12345678> <@U98765432> asdasd +++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = " sadfaa +++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "+++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "test message "
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "<@URY13AN12>"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)
    }

    func testThatItDoesNotParsesUsers_Negative() {
        expectedKarmaMessages = [KarmaMessage]()

        testMessage = "<@U12345678> <@U98765432> asdasd --"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = " sadfaa --"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "----"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "test message "
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "<@URY13AN12>"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)
    }

    func testThatItDoesParsesUsersAndHitsMaximum_Positive() {
        expectedKarmaMessages = [KarmaMessage(user: "U12345678", karma: 5)]

        testMessage = "<@U12345678> +++++++++++++++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "<@U12345678>++++++"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)
    }

    func testThatItDoesParsesUsersAndHitsMaximum_Negative() {
        expectedKarmaMessages = [KarmaMessage(user: "U12345678", karma: -5)]

        testMessage = "<@U12345678> ---------------"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)

        testMessage = "<@U12345678>------"
        XCTAssertEqual(parser.karmaMessages(from: testMessage), expectedKarmaMessages)
    }
}
