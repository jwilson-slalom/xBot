//
//  TestLogger.swift
//  AppTests
//
//  Created by Jacob Wilson on 3/12/19.
//

@testable import App
import Vapor
import XCTest

class TestLogger: Logger {
    func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {}
}
