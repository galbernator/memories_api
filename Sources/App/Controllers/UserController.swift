//
//  UserController.swift
//  App
//
//  Created by Steve on 12/27/18.
//

import Foundation
import FluentPostgreSQL
import Vapor
import Crypto

final class UserController {
    func create(_ request: Request, _ newUser: User) throws -> Future<User.PublicUser> {
        return User.query(on: request).filter(\.email == newUser.email).first().flatMap({ existingUser in
            guard existingUser == nil else {
                throw Abort(.badRequest, reason: "A user with that email already exists", identifier: nil)
            }

            let digest = try request.make(BCryptDigest.self)
            let hashedPassword = try digest.hash(newUser.password)
            let persistedUser = User(firstName: newUser.firstName,
                                     lastName: newUser.lastName,
                                     email: newUser.email,
                                     password:  hashedPassword,
                                     username: newUser.username)

            return persistedUser.save(on: request).flatMap(to: User.PublicUser.self) { createdUser in
                return try self.publicUser(from: createdUser, for: request)
            }
        })
    }

    func login(_ request: Request) throws -> Future<User.PublicUser> {
        return try request.content.decode(User.LoginRequest.self).flatMap(to: User.PublicUser.self) { loginRequest in
                let passwordVerifier = try request.make(BCryptDigest.self)
                return User
                    .authenticate(username: loginRequest.email, password: loginRequest.password, using: passwordVerifier, on: request)
                    .unwrap(or: Abort.init(HTTPResponseStatus.unauthorized))
                    .flatMap(to: User.PublicUser.self)  { user in
                        // remove all previous tokens for the user
                        _ = try user.authTokens.query(on: request).delete()
                        return try self.publicUser(from: user, for: request)
                }
        }
    }

    private func publicUser(from user: User, for request: Request) throws -> Future<User.PublicUser> {
        let token = try Token.createToken(forUser: user)
        return token.save(on: request).map(to: User.PublicUser.self) { createdToken in
            return User.PublicUser(
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                token: createdToken.token,
                username: user.username
            )
        }
    }
}
