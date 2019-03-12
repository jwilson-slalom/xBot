//
//  OnTapMemory.swift
//  App
//
//  Created by Allen Humphreys on 3/4/19.
//

import Foundation

enum OnTapMemory {

    // ~Absolutely~ getting closer to not entirely not threadsafe
    fileprivate static var leftBeerSetCount: Int64 = -1
    fileprivate static var rightBeerSetCount: Int64 = -1

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
            leftBeerSetCount += 1
            oldValue = kegSystem.leftBeer
            kegSystem.leftBeer = newBeer
        case .right:
            rightBeerSetCount += 1
            oldValue = kegSystem.rightBeer
            kegSystem.rightBeer = newBeer
        }

        kegSystem.updated = Date()

        guard oldValue != newBeer else { return false }

        // Ignores the initial set after the server starts up
        switch tap {
        case .left where leftBeerSetCount > 0:
            return true
        case .right where rightBeerSetCount > 0:
            return true
        default:
            return false
        }
    }
}
