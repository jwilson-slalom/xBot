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

    func testThatItParsesUserId() {
        let expectedUserIds = ["U12345678"]

        testMessage = "<@U12345678|jacob>"
        XCTAssertEqual(parser.userIds(from: testMessage), expectedUserIds)

        testMessage = "<@U12345678> adfsdf"
        XCTAssertEqual(parser.userIds(from: testMessage), expectedUserIds)

        testMessage = " asdfsdf  <@U12345678>  safdsf  sadf"
        XCTAssertEqual(parser.userIds(from: testMessage), expectedUserIds)
    }

    func testThatItParsesMultipleUserIds() {
        let expectedUserIds = ["U12345678", "U98765432"]

        testMessage = "<@U12345678|jacob><@U98765432>"
        XCTAssertEqual(parser.userIds(from: testMessage), expectedUserIds)

        testMessage = "other stuff <@U12345678> adfsdf ++ <@U98765432|someoneelse>"
        XCTAssertEqual(parser.userIds(from: testMessage), expectedUserIds)

        testMessage = "<@U12345678>      <@U98765432>"
        XCTAssertEqual(parser.userIds(from: testMessage), expectedUserIds)
    }

    func testThatItDoesNotParseUserIds() {
        let expectedUserIds = [String]()

        testMessage = "<@U1234567|jacob><@U98765432|>"
        XCTAssertEqual(parser.userIds(from: testMessage), expectedUserIds)

        testMessage = "<U12345678>"
        XCTAssertEqual(parser.userIds(from: testMessage), expectedUserIds)

        testMessage = " some other words <U12345678>"
        XCTAssertEqual(parser.userIds(from: testMessage), expectedUserIds)
    }

    func testThatItParsesMentionedUserIdFromKarmaStatusMessage() {
        let expectedMentionedId = "U12345678"

        testMessage = "<@U12345678> status dasfsdfas asdfsdff"
        guard let mentionedUserId = parser.karmaStatusMentionedUserId(from: testMessage) else {
            return XCTFail("mentionedUserId should not be nil")
        }
        XCTAssertEqual(mentionedUserId, expectedMentionedId)

        testMessage = "     <@U12345678|jacob>    stATuS      <U98765432>"
        guard let mentionedUserId2 = parser.karmaStatusMentionedUserId(from: testMessage) else {
            return XCTFail("mentionedUserId2 should not be nil")
        }
        XCTAssertEqual(mentionedUserId2, expectedMentionedId)
    }

    func testThatItFailsToParseMentionedUserIdFromKarmaStatusMessage() {

        testMessage = "something <@U12345678> status dasfsdfas asdfsdff"
        XCTAssertNil(parser.karmaStatusMentionedUserId(from: testMessage))

        testMessage = " <@U12345678|jacob>status      <U98765432>"
        XCTAssertNil(parser.karmaStatusMentionedUserId(from: testMessage))

        testMessage = " <@U12345678|jacob>  status<U98765432>"
        XCTAssertNil(parser.karmaStatusMentionedUserId(from: testMessage))

        testMessage = "<@U12345678|jacob> something status <U98765432>"
        XCTAssertNil(parser.karmaStatusMentionedUserId(from: testMessage))
    }

    func testThatItParsesMentionedUserIdFromKarmaLeaderboardMessage() {
        let expectedMentionedId = "U12345678"

        testMessage = "<@U12345678> leaderboard dasfsdfas asdfsdff"
        guard let mentionedUserId = parser.leaderboardMentionedUserId(from: testMessage) else {
            return XCTFail("mentionedUserId should not be nil")
        }
        XCTAssertEqual(mentionedUserId, expectedMentionedId)

        testMessage = "     <@U12345678|jacob>    lEADerBoard      <U98765432>"
        guard let mentionedUserId2 = parser.leaderboardMentionedUserId(from: testMessage) else {
            return XCTFail("mentionedUserId2 should not be nil")
        }
        XCTAssertEqual(mentionedUserId2, expectedMentionedId)

        testMessage = " <@U12345678|jacob>  leaderboard<U98765432>"
        guard let mentionedUserId3 = parser.leaderboardMentionedUserId(from: testMessage) else {
            return XCTFail("mentionedUserId3 should not be nil")
        }
        XCTAssertEqual(mentionedUserId3, expectedMentionedId)
    }

    func testThatItFailsToParseMentionedUserIdFromKarmaLeaderboardMessage() {

        testMessage = "something <@U12345678> leaderboard dasfsdfas asdfsdff"
        XCTAssertNil(parser.leaderboardMentionedUserId(from: testMessage))

        testMessage = " <@U12345678|jacob>leaderboard      <U98765432>"
        XCTAssertNil(parser.leaderboardMentionedUserId(from: testMessage))

        testMessage = "<@U12345678|jacob> something leaderboard <U98765432>"
        XCTAssertNil(parser.leaderboardMentionedUserId(from: testMessage))
    }

    func testThatItParsesMentionedUserIdFromKarmaHelpMessage() {
        let expectedMentionedId = "U12345678"

        testMessage = "<@U12345678> help dasfsdfas asdfsdff"
        guard let mentionedUserId = parser.helpMentionedUserId(from: testMessage) else {
            return XCTFail("mentionedUserId should not be nil")
        }
        XCTAssertEqual(mentionedUserId, expectedMentionedId)

        testMessage = "     <@U12345678|jacob>    hElP      <U98765432>"
        guard let mentionedUserId2 = parser.helpMentionedUserId(from: testMessage) else {
            return XCTFail("mentionedUserId2 should not be nil")
        }
        XCTAssertEqual(mentionedUserId2, expectedMentionedId)

        testMessage = " <@U12345678|jacob>  help<U98765432>"
        guard let mentionedUserId3 = parser.helpMentionedUserId(from: testMessage) else {
            return XCTFail("mentionedUserId3 should not be nil")
        }
        XCTAssertEqual(mentionedUserId3, expectedMentionedId)
    }

    func testThatItFailsToParseMentionedUserIdFromKarmaHelpMessage() {

        testMessage = "something <@U12345678> help dasfsdfas asdfsdff"
        XCTAssertNil(parser.helpMentionedUserId(from: testMessage))

        testMessage = " <@U12345678|jacob>help      <U98765432>"
        XCTAssertNil(parser.helpMentionedUserId(from: testMessage))

        testMessage = "<@U12345678|jacob> something help <U98765432>"
        XCTAssertNil(parser.helpMentionedUserId(from: testMessage))
    }
}
