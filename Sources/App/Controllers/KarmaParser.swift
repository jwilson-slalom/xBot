//
//  KarmaParser.swift
//  App
//
//  Created by Jacob Wilson on 2/28/19.
//

import Vapor

final class KarmaParser {
    private let posRegex = "^(<@([\\w].+?)>)[\\s]*(\\+{1,5}\\+)"
    private let negRegex = "^(<@([\\w].+?)>)[\\s]*(-{1,5}-)"

    let positiveRegex: NSRegularExpression!
    let negativeRegex: NSRegularExpression!

    init() {
        positiveRegex = try! NSRegularExpression(pattern: posRegex)
        negativeRegex = try! NSRegularExpression(pattern: negRegex)
    }

    func captureGroupsFrom(message: String) -> [KarmaMessage] {
        if let match = findMatch(regex: positiveRegex, message: message) {
            return match
        }

        if let match = findMatch(regex: negativeRegex, message: message) {
            return match
        }

        return []
    }

    func findMatch(regex: NSRegularExpression, message: String) -> [KarmaMessage]? {
        if let match = regex.firstMatch(in: message, range: NSRange(location: 0, length: message.count)) {
            return [createMessage(match: match, message: message)]
        }
        return []
    }

    func createMessage(match: NSTextCheckingResult, message: String) -> KarmaMessage {
        let parts = match.captureGroups(testedString: message)
        let karma: Int
        if parts[2].contains("+") {
            karma = parts[2].count - 1
        } else {
            karma = (parts[2].count - 1) * -1
        }
        return KarmaMessage(user: parts[1], karma: karma)
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
