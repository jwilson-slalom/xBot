import XCTest

extension KarmaAdjustmentCommandTests {
    static let __allTests = [
        ("testThatItCallsCompletionOnResponder", testThatItCallsCompletionOnResponder),
        ("testThatItDoesNotCallCompletionOnResponderWhenBadCompletionIsSentIn", testThatItDoesNotCallCompletionOnResponderWhenBadCompletionIsSentIn),
        ("testThatItDoesNotCallCompletionOnResponderWhenCantParseCommand", testThatItDoesNotCallCompletionOnResponderWhenCantParseCommand),
    ]
}

extension KarmaControllerTests {
    static let __allTests = [
        ("testThatItCreatesAHistory", testThatItCreatesAHistory),
        ("testThatItCreatesAStatus", testThatItCreatesAStatus),
        ("testThatItDoesNotAllowAUserToAdjustKarmaForSelf", testThatItDoesNotAllowAUserToAdjustKarmaForSelf),
        ("testThatItHandlesMultipleSlackResponsesFromMultipleAdjustmentMessages", testThatItHandlesMultipleSlackResponsesFromMultipleAdjustmentMessages),
        ("testThatItHandlesWhenValidAdjustmentMessageWithExistingStatus", testThatItHandlesWhenValidAdjustmentMessageWithExistingStatus),
        ("testThatItHandlesWhenValidAdjustmentMessageWithNoExistingStatus", testThatItHandlesWhenValidAdjustmentMessageWithNoExistingStatus),
        ("testThatItReturnsAllHistoryObjects", testThatItReturnsAllHistoryObjects),
        ("testThatItReturnsAllStatusObjects", testThatItReturnsAllStatusObjects),
        ("testThatItSendsOneSlackMessageFromValidLeaderboardCommandWithMultipleStatus", testThatItSendsOneSlackMessageFromValidLeaderboardCommandWithMultipleStatus),
        ("testThatItSendsOneSlackMessageFromValidStatusCommandWithMultipleStatus", testThatItSendsOneSlackMessageFromValidStatusCommandWithMultipleStatus),
        ("testThatItSendsResponseWhenErrorOccurs", testThatItSendsResponseWhenErrorOccurs),
        ("testThatItSendsSlackMessageFromValidHelpCommand", testThatItSendsSlackMessageFromValidHelpCommand),
        ("testThatItSendsSlackMessageFromValidLeaderboardCommand", testThatItSendsSlackMessageFromValidLeaderboardCommand),
        ("testThatItSendsSlackMessageFromValidLeaderboardCommandBadFutureReturned", testThatItSendsSlackMessageFromValidLeaderboardCommandBadFutureReturned),
        ("testThatItSendsSlackMessageFromValidLeaderboardCommandButEmptyStatusesReturned", testThatItSendsSlackMessageFromValidLeaderboardCommandButEmptyStatusesReturned),
        ("testThatItSendsSlackMessageFromValidStatusCommand", testThatItSendsSlackMessageFromValidStatusCommand),
        ("testThatItSendsSlackMessageFromValidStatusCommandBadFutureReturned", testThatItSendsSlackMessageFromValidStatusCommandBadFutureReturned),
        ("testThatItSendsSlackMessageFromValidStatusCommandButEmptyStatusesReturned", testThatItSendsSlackMessageFromValidStatusCommandButEmptyStatusesReturned),
        ("testThatItUpdatesAStatus", testThatItUpdatesAStatus),
    ]
}

extension KarmaHelpCommandTests {
    static let __allTests = [
        ("testThatItCallsCompletionOnResponder", testThatItCallsCompletionOnResponder),
        ("testThatItCallsCompletionOnResponderAndLinkIsCorrectForProduction", testThatItCallsCompletionOnResponderAndLinkIsCorrectForProduction),
        ("testThatItDoesNotCallCompletionBecauseMentionedIdDoesNotEqualBotUser", testThatItDoesNotCallCompletionBecauseMentionedIdDoesNotEqualBotUser),
        ("testThatItDoesNotCallCompletionOnResponderWhenBadCompletionIsSentIn", testThatItDoesNotCallCompletionOnResponderWhenBadCompletionIsSentIn),
    ]
}

extension KarmaLeaderboardCommandTests {
    static let __allTests = [
        ("testThatItCallsCompletionOnResponder", testThatItCallsCompletionOnResponder),
        ("testThatItDoesNotCallCompletionBecauseMentionedIdDoesNotEqualBotUser", testThatItDoesNotCallCompletionBecauseMentionedIdDoesNotEqualBotUser),
        ("testThatItDoesNotCallCompletionOnResponderWhenBadCompletionIsSentIn", testThatItDoesNotCallCompletionOnResponderWhenBadCompletionIsSentIn),
    ]
}

extension KarmaMessageParserTests {
    static let __allTests = [
        ("testThatItDoesNotParsesUsers_Negative", testThatItDoesNotParsesUsers_Negative),
        ("testThatItDoesNotParsesUsers_Positive", testThatItDoesNotParsesUsers_Positive),
        ("testThatItDoesNotParseUserIds", testThatItDoesNotParseUserIds),
        ("testThatItDoesParsesUsersAndHitsMaximum_Negative", testThatItDoesParsesUsersAndHitsMaximum_Negative),
        ("testThatItDoesParsesUsersAndHitsMaximum_Positive", testThatItDoesParsesUsersAndHitsMaximum_Positive),
        ("testThatItFailsToParseMentionedUserIdFromKarmaHelpMessage", testThatItFailsToParseMentionedUserIdFromKarmaHelpMessage),
        ("testThatItFailsToParseMentionedUserIdFromKarmaLeaderboardMessage", testThatItFailsToParseMentionedUserIdFromKarmaLeaderboardMessage),
        ("testThatItFailsToParseMentionedUserIdFromKarmaStatusMessage", testThatItFailsToParseMentionedUserIdFromKarmaStatusMessage),
        ("testThatItParsesMentionedUserIdFromKarmaHelpMessage", testThatItParsesMentionedUserIdFromKarmaHelpMessage),
        ("testThatItParsesMentionedUserIdFromKarmaLeaderboardMessage", testThatItParsesMentionedUserIdFromKarmaLeaderboardMessage),
        ("testThatItParsesMentionedUserIdFromKarmaStatusMessage", testThatItParsesMentionedUserIdFromKarmaStatusMessage),
        ("testThatItParsesMultipleUser_Negative", testThatItParsesMultipleUser_Negative),
        ("testThatItParsesMultipleUser_Positive", testThatItParsesMultipleUser_Positive),
        ("testThatItParsesMultipleUser_PositiveAndNegative", testThatItParsesMultipleUser_PositiveAndNegative),
        ("testThatItParsesMultipleUserIds", testThatItParsesMultipleUserIds),
        ("testThatItParsesOneUser_Negative", testThatItParsesOneUser_Negative),
        ("testThatItParsesOneUser_Positive", testThatItParsesOneUser_Positive),
        ("testThatItParsesUserId", testThatItParsesUserId),
    ]
}

extension KarmaStatusCommandTests {
    static let __allTests = [
        ("testThatItCallsCompletionOnResponder", testThatItCallsCompletionOnResponder),
        ("testThatItCallsCompletionOnResponderWhileFilteringOutAdditionalMentionedBotUser", testThatItCallsCompletionOnResponderWhileFilteringOutAdditionalMentionedBotUser),
        ("testThatItDoesNotCallCompletionBecauseMentionedIdDoesNotEqualBotUser", testThatItDoesNotCallCompletionBecauseMentionedIdDoesNotEqualBotUser),
        ("testThatItDoesNotCallCompletionBecauseParsedUserIdsContainsBotUserAndThenIsEmpty", testThatItDoesNotCallCompletionBecauseParsedUserIdsContainsBotUserAndThenIsEmpty),
        ("testThatItDoesNotCallCompletionBecauseParsedUserIdsIsEmpty", testThatItDoesNotCallCompletionBecauseParsedUserIdsIsEmpty),
        ("testThatItDoesNotCallCompletionOnResponderWhenBadCompletionIsSentIn", testThatItDoesNotCallCompletionOnResponderWhenBadCompletionIsSentIn),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(KarmaAdjustmentCommandTests.__allTests),
        testCase(KarmaControllerTests.__allTests),
        testCase(KarmaHelpCommandTests.__allTests),
        testCase(KarmaLeaderboardCommandTests.__allTests),
        testCase(KarmaMessageParserTests.__allTests),
        testCase(KarmaStatusCommandTests.__allTests),
    ]
}
#endif
