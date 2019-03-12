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
        case fallback, color, text, fields
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fallback, forKey: .fallback)
        try container.encode(color, forKey: .color)
        try container.encode(text, forKey: .text)
        try container.encode(fields, forKey: .fields)
    }
}

extension AttachmentField: Encodable {
    enum CodingKeys: String, CodingKey {
        case title, value, short
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(value, forKey: .value)
        try container.encode(short, forKey: .short)
    }
}
