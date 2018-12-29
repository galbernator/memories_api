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
        let userID = try request.parameters.next(Int.self)
        return User.find(userID, on: request).flatMap(to: [Person].self) { user in
            guard let user = user else {
                throw Abort(.notFound, reason: "Unable fo find requested user.", identifier: nil)
            }

            return try user.people.query(on: request).all()
        }
    }
}
