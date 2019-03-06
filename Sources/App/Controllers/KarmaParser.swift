//
//  KarmaParser.swift
//  App
//
//  Created by Jacob Wilson on 2/28/19.
//

import Vapor

final class KarmaParser {
    private static let posRegex = "(<@[\\w].+?>)[\\s]*(\\+{1,5}\\+)"
    private static let negRegex = "(<@[\\w].+?>)[\\s]*(-{1,5}-)"
    private static let userRegexString = "<@([\\w\\d]+)>"

    let positiveRegex = try! NSRegularExpression(pattern: posRegex)
    let negativeRegex = try! NSRegularExpression(pattern: negRegex)
    let userRegex = try! NSRegularExpression(pattern: userRegexString)

    func karmaMessages(from message: String) -> [KarmaMessage] {
        let positiveMessageMatch = findKarmaMatch(using: positiveRegex, on: message)
        if !positiveMessageMatch.isEmpty {
            return positiveMessageMatch
        }

        let negativeMessageMatch = findKarmaMatch(using: negativeRegex, on: message)
        if !negativeMessageMatch.isEmpty {
            return negativeMessageMatch
        }

        return []
    }

    private func findKarmaMatch(using regex: NSRegularExpression, on message: String) -> [KarmaMessage] {
        if let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..<message.endIndex, in: message)) {
            return process(match: match, on: message)
        }

        return []
    }

    private func process(match: NSTextCheckingResult, on message: String) -> [KarmaMessage] {
        let parts = match.captureGroups(testedString: message)
        let karma: Int
        if parts[1].contains("+") {
            karma = parts[1].count - 1
        } else {
            karma = (parts[1].count - 1) * -1
        }

        return usersFrom(message: parts[0]).map { userId in
            return KarmaMessage(user: userId, karma: karma)
        }
    }

    private func usersFrom(message: String) -> [String] {
        return userRegex.matches(in: message, range: NSRange(message.startIndex..<message.endIndex, in: message)).map { match in
            let groups = match.captureGroups(testedString: message)
            return groups[0]
        }
    }
}

extension KarmaParser: ServiceType {
    static func makeService(for container: Container) throws -> KarmaParser {
        return KarmaParser()
    }
}

private extension NSTextCheckingResult {

    func captureGroups(testedString: String) -> [String] {

        return (1..<numberOfRanges).compactMap {
            Range(range(at: $0), in: testedString).map { String(testedString[$0]) }
        }
    }
}
