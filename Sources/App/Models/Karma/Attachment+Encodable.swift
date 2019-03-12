//
//  Attachment+Encodable.swift
//  App
//
//  Created by Allen Humphreys on 3/7/19.
//

import SlackKit

/// Provides for how `Attachment` should be encoded for the slash command response
extension Attachment: Encodable {
    enum CodingKeys: String, CodingKey {
        case fallback, color, text
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fallback, forKey: .fallback)
        try container.encode(color, forKey: .color)
        try container.encode(text, forKey: .text)
    }
}
