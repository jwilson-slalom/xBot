//
//  KarmaParser.swift
//  App
//
//  Created by Jacob Wilson on 2/28/19.
//

import Vapor

final class KarmaParser {

    private static let karmaString = """
                    <@([\\w]{9}) (?# capture userId)
                    (?:|[^>]+){0,1}?> (?# optionally allow for the alternate ID slack syntax)
                    [\\s]* (?# optionally find any spaces before the +'s or -'s)
                    (\\+{2,6}|-{2,6}) (?# capture the +'s or -'s)
                    """

    private static let userString = """
                    <@([\\w]{9}) (?# capture userId)
                    (?:|[^>]+){0,1}?> (?# optionally allow for the alternate ID slack syntax)
                    """


    let karmaRegex = try! NSRegularExpression(pattern: karmaString, options: .allowCommentsAndWhitespace)
    let userRegex = try! NSRegularExpression(pattern: userString, options: .allowCommentsAndWhitespace)

    func karmaAdjustments(from message: String) -> [KarmaAdjustment] {
        return karmaRegex.matches(in: message, range: NSRange(message.startIndex..<message.endIndex, in: message)).map { match in
            return process(match: match, on: message)
        }
    }

    func userIds(from message: String) -> [String] {
        return userRegex.matches(in: message, range: NSRange(message.startIndex..<message.endIndex, in: message)).map { match in
            print(match)
            let groups = match.captureGroups(testedString: message)
            print(groups)
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
