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
    func index(_ request: Request) -> Future<[Memory]> {
        return Memory.query(on: request).all()
    }

    func create(_ request: Request) throws -> Future<Memory> {
        return try request.content.decode(Memory.self).flatMap({ memory in
            return memory.save(on: request)
        })
    }

    func show(_ request: Request) throws -> Future<Memory> {
        let memory = try request.parameters.next(Memory.self)
        return memory
    }

    func update(_ request: Request) throws -> Future<Memory> {
        return try flatMap(to: Memory.self, request.parameters.next(Memory.self), request.content.decode(Memory.self), { memory, updatedMemory in
                memory.title = updatedMemory.title
                memory.body = updatedMemory.body
                return memory.save(on: request)
            }
        )
    }

    func delete(_ request: Request) throws -> Future<HTTPStatus> {
        return try request.parameters.next(Memory.self).flatMap { memory in
            memory.delete(on: request).transform(to: HTTPStatus.noContent)
        }
    }
}
