//
//  Token.swift
//  App
//
//  Created by Steve on 12/27/18.
//

import Foundation
import FluentPostgreSQL
import Vapor
import Authentication

final class Token: PostgreSQLModel {
    var id: Int?
    let token: String
    let userID: Int

    init(token: String, userID: Int) {
        self.token = token
        self.userID = userID
    }

    var user: Parent<Token, User> {
        return parent(\.userID)
    }

    static func createToken(forUser user: User) throws -> Token {
        let tokenString = randomToken()
        let newToken = try Token(token: tokenString, userID: user.requireID())
        return newToken
    }

    private static func randomToken() -> String {
        let allowedChars = "$!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        for _ in 0 ..< 60 {
            let randomNumber = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNumber)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        return randomString
    }
}

extension Token: BearerAuthenticatable {
    static var tokenKey: TokenKey { return \Token.token as! Token.TokenKey }
}

extension Token: Authentication.Token {
    static var userIDKey: UserIDKey { return \Token.userID as! Token.UserIDKey }
    typealias UserType = User
    typealias UserIDType = User.ID
}

extension Token: Migration {}
