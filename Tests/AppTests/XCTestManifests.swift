import XCTest

extension KarmaControllerTests {
    static let __allTests = [
        ("testThatItCreatesAHistory", testThatItCreatesAHistory),
        ("testThatItCreatesAStatus", testThatItCreatesAStatus),
        ("testThatItFailsACommandRequestItCantValidate", testThatItFailsACommandRequestItCantValidate),
        ("testThatItFailsACommandRequestWhenNoResponseUrl", testThatItFailsACommandRequestWhenNoResponseUrl),
        ("testThatItHandlesMultipleSlackResponsesFromMultipleAdjustmentMessages", testThatItHandlesMultipleSlackResponsesFromMultipleAdjustmentMessages),
        ("testThatItHandlesWhenUserTriesToAdjustThemselves", testThatItHandlesWhenUserTriesToAdjustThemselves),
        ("testThatItHandlesWhenValidAdjustmentMessageWithExistingStatus", testThatItHandlesWhenValidAdjustmentMessageWithExistingStatus),
        ("testThatItHandlesWhenValidAdjustmentMessageWithNoExistingStatus", testThatItHandlesWhenValidAdjustmentMessageWithNoExistingStatus),
        ("testThatItReturnsAllHistoryObjects", testThatItReturnsAllHistoryObjects),
        ("testThatItReturnsAllStatusObjects", testThatItReturnsAllStatusObjects),
        ("testThatItReturnsOkWhenCommandRequestIsValidated", testThatItReturnsOkWhenCommandRequestIsValidated),
        ("testThatItSendsResponseWhenErrorOccurs", testThatItSendsResponseWhenErrorOccurs),
        ("testThatItUpdatesAStatus", testThatItUpdatesAStatus),
    ]
}

extension KarmaMessageParserTests {
    static let __allTests = [
        ("testThatItDoesNotParsesUsers_Negative", testThatItDoesNotParsesUsers_Negative),
        ("testThatItDoesNotParsesUsers_Positive", testThatItDoesNotParsesUsers_Positive),
        ("testThatItDoesParsesUsersAndHitsMaximum_Negative", testThatItDoesParsesUsersAndHitsMaximum_Negative),
        ("testThatItDoesParsesUsersAndHitsMaximum_Positive", testThatItDoesParsesUsersAndHitsMaximum_Positive),
        ("testThatItParsesMultipleUser_Negative", testThatItParsesMultipleUser_Negative),
        ("testThatItParsesMultipleUser_Positive", testThatItParsesMultipleUser_Positive),
        ("testThatItParsesMultipleUser_PositiveAndNegative", testThatItParsesMultipleUser_PositiveAndNegative),
        ("testThatItParsesOneUser_Negative", testThatItParsesOneUser_Negative),
        ("testThatItParsesOneUser_Positive", testThatItParsesOneUser_Positive),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(KarmaControllerTests.__allTests),
        testCase(KarmaMessageParserTests.__allTests),
    ]
}
#endif
