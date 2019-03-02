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
    func handleEvent(event: Event)
}

extension SlackResponder {
    static var serviceName: String { return String(reflecting: self) }
}
