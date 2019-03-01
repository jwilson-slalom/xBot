//
//  KarmaParser.swift
//  App
//
//  Created by Jacob Wilson on 2/28/19.
//

import Vapor

final class KarmaParser {
    private let posRegex = "^([A-Za-z0-9\\s_@#<>|]*)\\s?(\\+{1,4}\\+)"
    private let negRegex = "^([A-Za-z0-9\\s_@#<>|]*)\\s?(-{1,4}-)"

    func captureGroupsFrom(message: String) -> [String] {
        let positiveRegex = try! NSRegularExpression(pattern: posRegex)

        guard let match = positiveRegex.firstMatch(in: message, range: NSRange(location: 0, length: message.count)) else {
            return []
        }

        return match.captureGroups(testedString: message)
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
        for i in  1 ..< self.numberOfRanges
        {
            let group = String(testedString[Range(self.range(at: i), in: testedString)!])
            groups.append(group)
        }
        return groups
    }
}
