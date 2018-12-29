//
//  Person.swift
//  App
//
//  Created by Steve on 12/27/18.
//

import Foundation
import FluentPostgreSQL
import Vapor

final class Person: PostgreSQLModel {
    var id: Int?
    var firstName: String
    var lastName: String
    var avatar: String?
    var userID: Int

    init(firstName: String, lastName: String, avatar: String? = nil, userID: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
        self.userID = userID
    }

    var memories: Siblings<Person, Memory, MemoryPerson> {
        return siblings()
    }
}

extension Person: Content {}
extension Person: Migration {}
extension Person: Parameter {}
