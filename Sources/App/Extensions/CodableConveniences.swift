//
//  CodableConveniences.swift
//  App
//
//  Created by Allen Humphreys on 3/7/19.
//

import Foundation

extension KeyedDecodingContainer {

    func decode<T: Decodable>(forKey key: KeyedDecodingContainer.Key) throws -> T {
        return try decode(T.self, forKey: key)
    }

    func decodeIfPresent<T: Decodable>(forKey key: KeyedDecodingContainer.Key) throws -> T? {
        return try decodeIfPresent(T.self, forKey: key)
    }
}
