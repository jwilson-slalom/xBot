//
//  OnTapMemory.swift
//  App
//
//  Created by Allen Humphreys on 3/4/19.
//

import Foundation

enum OnTapMemory {

    // Absolutely not threadsafe
    fileprivate static var leftBeerChangeCount: Int64 = -1
    static var leftBeer: Beer?

    fileprivate static var rightBeerChangeCount: Int64 = -1
    static var rightBeer: Beer?

    static func set(beer newBeer: Beer?, on tap: Tap) -> Bool {
        var oldValue: Beer?
        switch tap {
        case .left:
            oldValue = leftBeer
            leftBeer = newBeer
        case .right:
            oldValue = rightBeer
            rightBeer = newBeer
        }

        func different(_ oldBeer: Beer?, _ newBeer: Beer?) -> Bool {
            switch (oldValue, newBeer) {
            case let (old?, new?) where old.untappdID != new.untappdID:
                fallthrough
            case (.none, .some), (.some, .none):
                return true
            default:
                return false
            }
        }

        // Ignores the initial set after the server starts

        if different(oldValue, newBeer) {
            switch tap {
            case .left:
                leftBeerChangeCount += 1
                if leftBeerChangeCount > 0 {
                    return true
                }
            case .right:
                rightBeerChangeCount += 1
                if rightBeerChangeCount > 0 {
                    return true
                }
            }
        }

        return false
    }
}
