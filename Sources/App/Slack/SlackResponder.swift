//
//  SlackResponder.swift
//  App
//
//  Created by Allen Humphreys on 3/2/19.
//

import SlackKit

protocol SlackResponder {
    static var serviceName: String { get }
    var eventTypes: [EventType] { get }
    func handle(incomingMessage: SlackKitIncomingMessage) throws
    func handle(event: Event) throws
}

extension SlackResponder {
    static var serviceName: String { return String(reflecting: self) }
    var eventTypes: [EventType] { return [.message] }
    func handle(incomingMessage: SlackKitIncomingMessage) { }
    func handle(event: Event) { }
}
