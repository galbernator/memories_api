//
//  Memory.swift
//  App
//
//  Created by Steve on 12/25/18.
//

import Foundation
import FluentPostgreSQL
import Vapor

final class Memory: PostgreSQLModel {
    var id: Int?
    var title: String
    var body: String
    var userID: Int

    init(title: String, body: String, userID: Int) {
        self.title = title
        self.body = body
        self.userID = userID
    }

    var people: Siblings<Memory, Person, MemoryPerson> {
        return siblings()
    }
}

extension Memory: Migration {}
extension Memory: Content {}
extension Memory: Parameter {}
