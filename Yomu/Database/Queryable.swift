//
//  Queryable.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-24.
//

import Foundation
import SwiftData

/// An error thrown when a database operation fails.
public enum QueryError<PersistentModelType: PersistentModel>: Error {
    case itemNotFound(Selector<PersistentModelType>.Get)
}

/// Queryable types implement standard create, read, update, and replace database operations.
public protocol Queryable: Sendable {
    /// Saves the current state to a persistent data store.
    ///
    /// - Throws: an error if the current state could not be saved.
    func save() async throws
    
    /// Inserts a new persistent model into a model context.
    ///
    /// - Parameters:
    ///     - insertClosure: a closure that creates a new perisistent model.
    ///     - completion: a closure that performs some work on a persistent model and returns `T`.
    ///
    /// - Returns: the transformed result of calling the completion closure on a`PersistentModelType`.
    func insert<PersistentModelType: PersistentModel, T: Sendable>(_ insertClosure: @escaping @Sendable () -> PersistentModelType, with completion: @escaping @Sendable (PersistentModelType) throws -> T) async rethrows -> T
    
    /// Retrieves an optional value from a model context.
    ///
    /// - Parameters:
    ///     - selector: a database get operation.
    ///     - completion: a closure that performs some work on an optional persistent model and returns `T`.
    ///
    /// - Returns:  the transformed result of calling the completion closure on a`PersistentModelType?`.
    ///
    /// - Throws: any error thrown when executing the passed closure.
    func getOptional<PersistentModelType: PersistentModel, T: Sendable>(for selector: Selector<PersistentModelType>.Get, with completion: @escaping @Sendable (PersistentModelType?) throws -> T) async rethrows -> T
    
    /// Retrives a collection of persistent models from a model context.
    ///
    /// - Parameters:
    ///     - selector: a database fetch operation.
    ///     - completion: a closure that performs some work on an array of persistent models and returns `T`.
    ///
    /// - Returns: the transformed result of calling the completion closure on an array of `PersistentModelType`.
    ///
    /// - Throws: any error thrown when executing the passed closure.
    func fetch<PersistentModelType, T: Sendable>(for selector: Selector<PersistentModelType>.List, with completion: @escaping @Sendable ([PersistentModelType]) throws -> T) async rethrows -> T
    
    /// Removes one or more persistent models from a model context.
    ///
    /// - Parameter selector: a database delete operation.
    ///
    /// - Throws: an error if a specified item could not be found, or deleted.
    func delete<PersistentModelType>(_ selector: Selector<PersistentModelType>.Delete) async throws
}

extension Queryable {
    /// Inserts a new persistent model into the database.
    ///
    /// - Parameters:
    ///     - completion: a clouser that produces a persistent model.
    ///
    /// - Returns: the inserted persistent model wrapped by the `Model` type.
    @discardableResult public func insert<PersistentModelType: PersistentModel>(_ completion: @escaping @Sendable () -> PersistentModelType) async -> Model<PersistentModelType> {
        return await self.insert(completion, with: Model.init)
    }
    
    /// Retrieves an optional persistent model from the database.
    ///
    /// - Parameter selector: the query criteria used to fetch a model.
    ///
    /// - Returns: the retrieved optional persistent model wrapped by the `Model` type.
    public func getOptional<PersistentModelType>(for selector: Selector<PersistentModelType>.Get) async -> Model<PersistentModelType>? {
        return await self.getOptional(for: selector) { $0.flatMap(Model.init) }
    }
    
    /// Retrieves an array of persistent models that match the given selector list.
    ///
    /// - Parameter selector: the query criteria used to filter the requested models.
    ///
    /// - Returns: an array of wrapped persistent models.
    public func fetch<PersistentModelType>(for selector: Selector<PersistentModelType>.List) async -> [Model<PersistentModelType>] {
        await self.fetch(for: selector) { $0.map(Model.init) }
    }
    
    /// Retrieves and transforms an array of persistent models using multplie selectors.
    ///
    /// - Parameters:
    ///     - selectors: an array of various database gets operations.
    ///     - completion: a closure that transforms a persistent model into a specified type `T`.
    ///
    /// - Returns: an array of models transformed by the given closure.
    ///
    /// - Throws: a `QuerryError.itemNotFound` if the requested models are not in the database.
    public func fetch<PersistentModelType, T: Sendable>(for selectors: [Selector<PersistentModelType>.Get], with completion: @escaping @Sendable (PersistentModelType) throws -> T) async rethrows -> [T] {
        try await withThrowingTaskGroup(of: Optional<T>.self, returning: [T].self, body: { group in
            for selector in selectors {
                group.addTask {
                    try await self.getOptional(for: selector) { peristentModel in
                        guard let peristentModel else { return Optional<T>.none }
                        return try completion(peristentModel)
                    }
                }
            }
            return try await group.reduce(into: [T]()) { partial, result in
                if let result { partial.append(result) }
            }
        })
    }
    
    /// Retrieves a specific model type.
    ///
    /// - Parameter selector: the query criteria used to fetch the requested model.
    ///
    /// - Returns: a persistent model wrapped by the `Model` type.
    ///
    /// - Throws: a `QuerryError.itemNotFound` if the requested model is not in the dat base.
    public func get<PersistentModelType>(for selector: Selector<PersistentModelType>.Get) async throws -> Model<PersistentModelType> {
        try await self.getOptional(for: selector) { persistentModel in
            guard let persistentModel else { throw QueryError.itemNotFound(selector) }
            return Model(persistentModel)
        }
    }
    
    /// Retrieves and transforms specific model type.
    ///
    /// - Parameters:
    ///     - selector: the query criteria used to fetch the requested model.
    ///     - completion: a closure that creates the requested model type from the given persistent model.
    ///
    /// - Returns: the result of the completion closure.
    ///
    /// - Throws: a `QuerryError.itemNotFound` if the requested model is not in the database.
    public func get<PersistentModelType, T: Sendable>(for selector: Selector<PersistentModelType>.Get, with completion: @escaping @Sendable (PersistentModelType) throws -> T) async rethrows -> T {
        try await self.getOptional(for: selector) { persistentModel in
            guard let persistentModel else { throw QueryError.itemNotFound(selector) }
            return try completion(persistentModel)
        }
    }
    
    /// Updates the persistent model defined by the given selector.
    ///
    /// - Parameters:
    ///     - selector: a query that defines a single persistent model.
    ///     - completion:  a closure that updates a selected persistent model.
    ///
    /// - Throws: a `QuerryError.itemNotFound` if the requested model is not in the database.
    public func update<PersistentModelType>(for selector: Selector<PersistentModelType>.Get, with completion: @escaping @Sendable (PersistentModelType) throws -> Void) async throws {
        try await self.get(for: selector, with: completion)
    }
    
    /// Updates the persistent models defined by the given selector.
    ///
    /// - Parameters:
    ///     - selector: a query that defines a collection persistent models.
    ///     - completion:  a closure that updates a selected persistent models.
    ///
    /// - Throws: any error thrown by the completion closure.
    public func update<PersistentModelType>(for selector: Selector<PersistentModelType>.List, with completion: @escaping @Sendable ([PersistentModelType]) throws -> Void) async throws {
        try await self.fetch(for: selector, with: completion)
    }
    
    /// Conditionally inserts a new model into the database if it is not already stored.
    ///
    /// - Parameters:
    ///     - model: a closure that creates the specified model.
    ///     - selector: a closure that creates a selector to check for the specifed model's existentce.
    ///
    /// - Returns: The existing model, or the inserted model wrapped by the `Model` type.
    public func insert<PersistentModelType>(if model: @escaping @Sendable () -> PersistentModelType, doesNotAlreadyExist selector: @escaping @Sendable (PersistentModelType) -> Selector<PersistentModelType>.Get) async -> Model<PersistentModelType> {
        async let result = self.getOptional(for: selector(model()))
        if let model = await result { return model } else { return await self.insert(model) }
    }
    
    /// Conditionally inserts and transforms a new model into the database if it is not already stored.
    ///
    /// - Parameters:
    ///     - model: a closure that creates the specified model.
    ///     - selector: a closure that creates a selector to check for the specifed model's existentce.
    ///     - completion: a closure that transforms a persistent model into a specified type `T`.
    ///
    /// - Returns: The result of the completion closure.
    ///
    /// - Throws: any error thrown by the completion closure.
    public func insert<PersistentModelType, T: Sendable>(if model: @escaping @Sendable () -> PersistentModelType, doesNotAlreadyExist selector: @escaping @Sendable (PersistentModelType) -> Selector<PersistentModelType>.Get, with completion: @escaping @Sendable (PersistentModelType) throws -> T) async throws -> T {
        async let model = self.insert(if: model, doesNotAlreadyExist: selector)
        return try await self.get(for: .model(await model), with: completion)
    }
    
    /// Deletes the specifed models from the database.
    ///
    /// - Parameter models: the models to delete.
    ///
    /// - Throws: any errors thrown when attemping to delete the specifeid models.
    public func delete<PersistentModelType>(models: [Model<PersistentModelType>]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for model in models {
                group.addTask { try await self.delete(.model(model)) }
            }
            try await group.waitForAll()
        }
    }
}

