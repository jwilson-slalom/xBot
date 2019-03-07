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
    fileprivate static var rightBeerChangeCount: Int64 = -1

    private static let lock = DispatchQueue(label: "responders.lock", qos: .default, attributes: .concurrent)
    static private var _kegSystem = KegSystem(leftBeer: nil, rightBeer: nil, updated: .distantPast)
    static private(set) var kegSystem: KegSystem {
        get { return lock.sync { _kegSystem } }
        set { lock.async(flags: .barrier) { _kegSystem = newValue } }
    }

    static func set(beer newBeer: Beer?, on tap: Tap) -> Bool {
        var oldValue: Beer?
        switch tap {
        case .left:
            oldValue = kegSystem.leftBeer
            kegSystem.leftBeer = newBeer
        case .right:
            oldValue = kegSystem.rightBeer
            kegSystem.rightBeer = newBeer
        }

        kegSystem.updated = Date()

        func different(_ oldBeer: Beer?, _ newBeer: Beer?) -> Bool {
            switch (oldValue, newBeer) {
            case let (old?, new?) where old.untappdID != new.untappdID:
                fallthrough
            case (.none, .some), (.some, .none):
                return true
            case (.none, .none), (.some, .some):
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
