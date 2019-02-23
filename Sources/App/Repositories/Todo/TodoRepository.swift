//
//  TodoRepository.swift
//  App
//
//  Created by Jacob Wilson on 2/22/19.
//

import Vapor

protocol TodoRepository: ServiceType {
    func all() -> Future<[Todo]>
    func save(user: Todo) -> Future<Todo>
}

extension Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}
