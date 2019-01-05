//
//  MemoryController.swift
//  App
//
//  Created by Steve on 12/25/18.
//

import Foundation
import FluentPostgreSQL
import Vapor

final class MemoryController {
    func index(_ request: Request) throws -> Future<[Memory]> {
        return try authenticatedUserMemories(from: request).all()
    }

    func create(_ request: Request) throws -> Future<Memory> {
        let userID = try request.requireAuthenticated(User.self).requireID()
        return try request.content.decode(MemoryRequest.self).flatMap({ memoryRequest in
            let memory = Memory(title: memoryRequest.title, body: memoryRequest.body, userID: userID)
            return memory.save(on: request)
        })
    }

    func show(_ request: Request) throws -> Future<Memory> {
        return try userMemory(from: request).map { memory in
            guard let memory = memory else {
                throw Abort(.badRequest, reason: "Unable to find requested memory.", identifier: nil)
            }

            return memory
        }
    }

    func update(_ request: Request) throws -> Future<Memory> {
        return  try userMemory(from: request).flatMap { memory in
            guard let memory = memory else {
                throw Abort(.badRequest, reason: "Unable to find requested memory.", identifier: nil)
            }

            return try request.content.decode(MemoryRequest.self).flatMap { updatedMemory in
                memory.title = updatedMemory.title
                memory.body = updatedMemory.body
                return memory.save(on: request)
            }
        }
    }

    func delete(_ request: Request) throws -> Future<HTTPStatus> {
        return try userMemory(from: request).flatMap { memory in
            guard let memory = memory else {
                throw Abort(.badRequest, reason: "Unable to find requested memory.", identifier: nil)
            }

            return memory.delete(on: request).transform(to: HTTPStatus.noContent)
        }
    }

    private func authenticatedUserMemories(from request: Request) throws -> QueryBuilder<PostgreSQLDatabase, Memory> {
        let user = try request.requireAuthenticated(User.self)
        return try user.memories.query(on: request)
    }

    private func userMemory(from request: Request) throws -> EventLoopFuture<Memory?> {
        let memoryID = try request.parameters.next(Int.self)
        return try authenticatedUserMemories(from: request).filter(\.id == memoryID).first()
    }

    private struct MemoryRequest: Content {
        let title: String
        let body: String
    }
}
