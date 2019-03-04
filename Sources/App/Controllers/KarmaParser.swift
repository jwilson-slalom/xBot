//
//  KarmaParser.swift
//  App
//
//  Created by Jacob Wilson on 2/28/19.
//

import Vapor

final class KarmaParser {
    private let posRegex = "(<@[\\w].+?>)[\\s]*(\\+{1,5}\\+)"
    private let negRegex = "(<@[\\w].+?>)[\\s]*(-{1,5}-)"
    private let userRegexString = "<@([\\w\\d]+)>"

    let positiveRegex: NSRegularExpression!
    let negativeRegex: NSRegularExpression!
    let userRegex: NSRegularExpression!

    init() {
        positiveRegex = try! NSRegularExpression(pattern: posRegex)
        negativeRegex = try! NSRegularExpression(pattern: negRegex)
        userRegex = try! NSRegularExpression(pattern: userRegexString)
    }

    func karmaMessages(from message: String) -> [KarmaMessage] {
        if let match = findKarmaMatch(using: positiveRegex, on: message) {
            return match
        }

        if let match = findKarmaMatch(using: negativeRegex, on: message) {
            return match
        }

        return []
    }

    private func findKarmaMatch(using regex: NSRegularExpression, on message: String) -> [KarmaMessage]? {
        if let match = regex.firstMatch(in: message, range: NSRange(location: 0, length: message.count)) {
            return process(match: match, on: message)
        }
        return nil
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
        return userRegex.matches(in: message, range: NSRange(location: 0, length: message.count)).map { match in
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
    func captureGroups(testedString:String) -> [String] {
        var groups = [String]()
        for i in  1 ..< self.numberOfRanges {
            let group = String(testedString[Range(self.range(at: i), in: testedString)!])
            groups.append(group)
        }
        return groups
    }
}
