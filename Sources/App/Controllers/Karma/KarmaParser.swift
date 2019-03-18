//
//  KarmaParser.swift
//  App
//
//  Created by Jacob Wilson on 2/28/19.
//

import Vapor

protocol KarmaParser {
    func karmaAdjustments(from message: String) -> [KarmaAdjustment]
    func userIds(from message: String) -> [String]
    func karmaStatusMentionedUserId(from message: String) -> String?
}

final class KarmaMessageParser: KarmaParser {

    private static let karmaAdjustmentString = """
                    <@([\\w]{9}) (?# capture userId)
                    (?:\\|{1}[^>]+){0,1}?> (?# optionally allow for the alternate ID slack syntax)
                    [\\s]* (?# optionally find any spaces before the +'s or -'s)
                    (\\+{2,6}|-{2,6}) (?# capture the +'s or -'s)
                    """

    private static let userString = """
                    <@([\\w]{9}) (?# capture userId)
                    (?:\\|{1}[^>]+){0,1}?> (?# optionally allow for the alternate ID slack syntax)
                    """

    private static let karmaStatusBeginningString = """
                    ^\\s*<@([\\w]{9}) (?# capture userId that starts at the beginning of the message)
                    (?:\\|{1}[^>]+){0,1}?> (?# optionally allow for the alternate ID slack syntax)
                    \\s+status\\s+  (?# require status after)
                    """


    let karmaAdjustmentRegex = try! NSRegularExpression(pattern: karmaAdjustmentString, options: .allowCommentsAndWhitespace)
    let karmaStatusRegex = try! NSRegularExpression(pattern: karmaStatusBeginningString, options: [.allowCommentsAndWhitespace, .caseInsensitive])
    let userRegex = try! NSRegularExpression(pattern: userString, options: .allowCommentsAndWhitespace)

    func karmaAdjustments(from message: String) -> [KarmaAdjustment] {
        return karmaAdjustmentRegex.matches(in: message, range: NSRange(message.startIndex..<message.endIndex, in: message)).map { match in
            return process(match: match, on: message)
        }
    }

    func userIds(from message: String) -> [String] {
        return userRegex.matches(in: message, range: NSRange(message.startIndex..<message.endIndex, in: message)).map { match in
            let groups = match.captureGroups(testedString: message)
            return groups[0]
        }
    }

    func karmaStatusMentionedUserId(from message: String) -> String? {
        return karmaStatusRegex.firstMatch(in: message, range: NSRange(message.startIndex..<message.endIndex, in: message)).map { match in
            let groups = match.captureGroups(testedString: message)
            return groups[0]
        }
    }

    private func process(match: NSTextCheckingResult, on message: String) -> KarmaAdjustment {
        let groups = match.captureGroups(testedString: message)

        let userId = groups[0]
        let karma = (groups[1].count - 1) * (groups[1].contains("+") ? 1 : -1)

        return KarmaAdjustment(user: userId, count: karma)
    }
}

private extension NSTextCheckingResult {

    func captureGroups(testedString: String) -> [String] {

        // index 0 is excluded because that represents the complete match
        return (1..<numberOfRanges).compactMap {
            Range(range(at: $0), in: testedString).map { String(testedString[$0]) }
        }
    }
}
