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
    func send(message: SlackKitSendable) throws {
        print("SendMessage")
    }

    func send(message: SlackKitSendable, onlyVisibleTo user: String) throws {
        print("SendMessage Visibile to user")
    }
}
