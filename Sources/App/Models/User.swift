//
//  User.swift
//  App
//
//  Created by Steve on 12/27/18.
//

import Foundation
import FluentPostgreSQL
import Vapor
import Authentication

final class User: PostgreSQLModel {

    struct PublicUser {
        let firstName: String
        let lastName: String
        let email: String
        let token: String
        let username: String
    }

    struct LoginRequest {
        let email: String
        let password: String
    }

    var id: Int?
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let username: String

    init(firstName: String, lastName: String, email: String, password: String, username: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.username = username
    }

    var memories: Children<User, Memory> {
        return children(\.userID)
    }

    var people: Children<User, Person> {
        return children(\.userID)
    }
}

extension User: PasswordAuthenticatable {
    static var usernameKey: UsernameKey {
        return \User.email as! User.UsernameKey
    }
    static var passwordKey: PasswordKey {
        return \User.password as! User.PasswordKey
    }
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.email)
        }
    }
}

extension User: Content {}
extension User: Parameter {}
extension User.PublicUser: Content {}
extension User.LoginRequest: Content {}
