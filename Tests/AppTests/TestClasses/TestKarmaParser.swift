//
//  TestKarmaParser.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/12/19.
//

@testable import App
import XCTest

class TestKarmaParser: KarmaParser {
    var karmaAdjustments = [KarmaAdjustment]()
    var userIds = [String]()
    var mentionedUserId: String?

    func karmaAdjustments(from message: String) -> [KarmaAdjustment] {
        return karmaAdjustments
    }

    func userIds(from message: String) -> [String] {
        return userIds
    }

    func karmaStatusMentionedUserId(from message: String) -> String? {
        return mentionedUserId
    }
}
