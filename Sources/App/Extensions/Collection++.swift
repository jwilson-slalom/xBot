//
//  Extensions.swift
//  App
//
//  Created by Allen Humphreys on 3/6/19.
//

import Foundation

extension Collection {

    var isNotEmpty: Bool {
        return !isEmpty
    }

    func isValidIndex(_ index: Index) -> Bool {
        return indices.contains(index)
    }

    subscript(optional index: Index) -> Element? {
        guard isValidIndex(index) else { return nil }

        return self[index]
    }
}
