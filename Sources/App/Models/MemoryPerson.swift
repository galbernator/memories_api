//
//  MemoryPerson.swift
//  App
//
//  Created by Steve on 12/27/18.
//

import Foundation
import FluentPostgreSQL
import Vapor

struct MemoryPerson: PostgreSQLPivot {
    typealias Left = Memory
    typealias Right = Person

    static var leftIDKey: LeftIDKey = \.memoryID
    static var rightIDKey: RightIDKey = \.personID

    var id: Int?
    var memoryID: Int
    var personID: Int
}

extension MemoryPerson: ModifiablePivot {
    init(_ left: Memory, _ right: Person) throws {
        self.memoryID = try left.requireID()
        self.personID = try right.requireID()
    }
}

extension MemoryPerson: PostgreSQLMigration {}
