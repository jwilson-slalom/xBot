//
//  TestSlack.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/12/19.
//

@testable import App
import Vapor
import XCTest

class TestSlack: SlackMessageSender {

    var sendMessageHandler: ((SlackKitSendable) -> Void)?
    var sendMessageToUserHandler: ((SlackKitSendable, String) -> Void)?

    func send(message: SlackKitSendable) throws {
        sendMessageHandler?(message)
    }

    func send(message: SlackKitSendable, onlyVisibleTo user: String) throws {
        sendMessageToUserHandler?(message, user)
    }
}
