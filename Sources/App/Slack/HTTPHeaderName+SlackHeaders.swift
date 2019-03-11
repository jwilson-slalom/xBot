//
//  HTTPHeaderName+SlackHeaders.swift
//  App
//
//  Created by Allen Humphreys on 3/8/19.
//

import Vapor

public extension HTTPHeaderName {
    static let slackSignature = HTTPHeaderName("X-Slack-Signature")
    static let slackTimestamp = HTTPHeaderName("X-Slack-Request-Timestamp")
}
