//
//  KarmaParserTests.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/4/19.
//

@testable import App
import XCTest

final class KarmaMessageParserTests: XCTestCase {

    var testMessage: String!
    var expectedKarmaMessages: [KarmaAdjustment]!

    var parser: KarmaMessageParser!

    override func setUp() {
        parser = KarmaMessageParser()
    }

    func testThatItParsesOneUser_Positive() {
        expectedKarmaMessages = [KarmaAdjustment(user: "U12345678", count: 1)]

        testMessage = "<@U12345678|jacob>++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "<@U12345678> ++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "   <@U12345678>  ++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)
    }

    func testThatItParsesOneUser_Negative() {
        expectedKarmaMessages = [KarmaAdjustment(user: "U12345678", count: -1)]

        testMessage = "<@U12345678|jacob>--"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "<@U12345678> --"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = " asdfa <@U12345678> --"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)
    }

    func testThatItParsesMultipleUser_Positive() {
        expectedKarmaMessages = [KarmaAdjustment(user: "U12345678", count: 2),
                                 KarmaAdjustment(user: "U98765432", count: 2)]

        testMessage = "<@U12345678>+++ <@U98765432>+++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "<@U12345678|jacob> +++ <@U98765432> +++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = " sadfa <@U12345678>+++ <@U98765432|allen>   +++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        expectedKarmaMessages = [KarmaAdjustment(user: "URY13AN12", count: 1),
                                 KarmaAdjustment(user: "U12345678", count: 3),
                                 KarmaAdjustment(user: "U98765432", count: 2)]

        testMessage = "<@URY13AN12>++ apples <@U12345678>++++ <@U98765432> +++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "<@URY13AN12>++   asdf    <@U12345678>   ++++ <@U98765432> +++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)
    }

    func testThatItParsesMultipleUser_Negative() {
        expectedKarmaMessages = [KarmaAdjustment(user: "U12345678", count: -2),
                                 KarmaAdjustment(user: "U98765432", count: -2)]

        testMessage = "<@U12345678>--- <@U98765432>---"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "<@U12345678|jacob> --- <@U98765432> ---"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = " sadfa <@U12345678>--- <@U98765432|allen>   ---"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        expectedKarmaMessages = [KarmaAdjustment(user: "URY13AN12", count: -1),
                                 KarmaAdjustment(user: "U12345678", count: -3),
                                 KarmaAdjustment(user: "U98765432", count: -2)]

        testMessage = "<@URY13AN12>-- apples <@U12345678>---- <@U98765432> ---"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "<@URY13AN12>--   asdf    <@U12345678>   ---- <@U98765432> ---"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)
    }

    func testThatItParsesMultipleUser_PositiveAndNegative() {
        expectedKarmaMessages = [KarmaAdjustment(user: "U12345678", count: -2),
                                 KarmaAdjustment(user: "U98765432", count: 2)]

        testMessage = "<@U12345678>--- <@U98765432>+++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "<@U12345678|jacob> --- <@U98765432> +++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = " sadfa <@U12345678>--- <@U98765432|allen>   +++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        expectedKarmaMessages = [KarmaAdjustment(user: "URY13AN12", count: 1),
                                 KarmaAdjustment(user: "U12345678", count: -3),
                                 KarmaAdjustment(user: "U98765432", count: 2)]

        testMessage = "<@URY13AN12>++ apples <@U12345678>---- <@U98765432> +++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "<@URY13AN12>++   asdf    <@U12345678>   ---- <@U98765432> +++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)
    }

    func testThatItDoesNotParsesUsers_Positive() {
        expectedKarmaMessages = [KarmaAdjustment]()

        testMessage = "<@U12345678> <@U98765432> asdasd +++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = " sadfaa +++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "+++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "test message "
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "<@URY13AN12>"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)
    }

    func testThatItDoesNotParsesUsers_Negative() {
        expectedKarmaMessages = [KarmaAdjustment]()

        testMessage = "<@U12345678> <@U98765432> asdasd --"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = " sadfaa --"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "----"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "test message "
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "<@URY13AN12>"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)
    }

    func testThatItDoesParsesUsersAndHitsMaximum_Positive() {
        expectedKarmaMessages = [KarmaAdjustment(user: "U12345678", count: 5)]

        testMessage = "<@U12345678> +++++++++++++++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "<@U12345678>++++++"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)
    }

    func testThatItDoesParsesUsersAndHitsMaximum_Negative() {
        expectedKarmaMessages = [KarmaAdjustment(user: "U12345678", count: -5)]

        testMessage = "<@U12345678> ---------------"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)

        testMessage = "<@U12345678>------"
        XCTAssertEqual(parser.karmaAdjustments(from: testMessage), expectedKarmaMessages)
    }
}
