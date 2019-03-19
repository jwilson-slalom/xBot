//
//  SlackCommand.swift
//  App
//
//  Created by Jacob Wilson on 3/18/19.
//

import SlackKit

protocol SlackCommand {
    var incomingMessage: SlackKitIncomingMessage { get }
}

protocol SlackCommandResponder {
    func handle(incomingMessage: SlackKitIncomingMessage, botUser: User) throws
    func register<C>(completion: @escaping (C, User) throws -> Void) -> Bool
}
