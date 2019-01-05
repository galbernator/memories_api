//
//  PersonController.swift
//  App
//
//  Created by Steve on 12/28/18.
//

import Foundation
import FluentPostgreSQL
import Vapor

final class PersonController {
    func index(_ request: Request) throws -> Future<[Person]> {
        let user = try request.requireAuthenticated(User.self)
        return try user.people.query(on: request).all()
    }
}
