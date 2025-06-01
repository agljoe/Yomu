//
//  ModelContext.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-27.
//

import Foundation
import SwiftData

extension ModelContext {
    /// Retrieves a persistent model of type `T` that has the given ID.
    ///
    /// - Parameter objectID: the peristent identitfier of the model to fetch.
    ///
    /// - Returns: an the requested model wrapped as an optional.
    ///
    /// - Throws: a SwiftData error describing why the fetch operation failed.
    private func persistentModel<T: PersistentModel>(withID objectID: PersistentIdentifier) throws -> T? {
        if let registered: T = registeredModel(for: objectID) { return registered }
        if let notRegistered: T = model(for: objectID) as? T { return notRegistered }
        let fetchDescriptor = FetchDescriptor<T>(predicate: #Predicate { $0.persistentModelID == objectID }, fetchLimit: 1)
        return try fetch(fetchDescriptor).first
    }
    
    /// Retrieves an optional persisten model.
    ///
    /// - Parameter model: a wrapped type used to fetch a persistent model.
    ///
    /// - Returns: the requested model.
    ///
    /// - Throws: a SwiftData error describing why the fetch operation failed.
    public func getOptional<T: PersistentModel>(_  model: Model<T>) throws -> T? {
        try self.persistentModel(withID: model.persistentIdentifier)
    }
}

extension ModelContext {
    /// Retrieves the first persistent model that matches the given predicate:
    ///
    /// - Parameter predicate: a logical condition used to search for matching models.
    ///
    /// - Returns: the first available model, nil if none could be found.
    ///
    /// - Throws: a SwiftData error describing why the fetch operation failed.
    public func first<PersistentModelType: PersistentModel>(where predicate: Predicate<PersistentModelType>? = nil) throws -> PersistentModelType? {
        try self.fetch(FetchDescriptor<PersistentModelType>(predicate: predicate, fetchLimit: 1)).first
    }
    
    /// Inserts a persistent model into this model context.
    ///
    /// - Parameter completion: a closure that creates a new instance of a the specified persistent model
    ///
    /// - Returns: the inserted model wrapped by the `Model` type.
    public func insert<T: PersistentModel>(_ completion: @escaping @Sendable () -> T) -> Model<T> {
        let model = completion()
        self.insert(model)
        return .init(model)
    }
    
    /// Inserts and transforms a persistent model.
    ///
    /// - Parameters:
    ///     - closure: a function that creates a new instance of a the specified persistent model
    ///     - completion: a closure that produces the specifed `T` from a given persistent model.
    ///
    /// - Returns: the restult of the completion closure.
    ///
    /// - Throws: a SwiftData error describing why the insert operation failed.
    func insert<PersistentModelType: PersistentModel, T: Sendable>(_ closure: @escaping @Sendable () -> PersistentModelType, with completion: @escaping @Sendable (PersistentModelType) throws -> T) rethrows -> T {
        let model = closure()
        self.insert(model)
        return try completion(model)
    }

    /// Retrieves a persistent model from this model context.
    ///
    /// - Parameter model: a wrapped persistent model.
    ///
    /// - Returns: the request persistent model wrapped as an optional.
    ///
    /// - Throws: a `QuerryError.itemNotFound` if the requested model could not be found in this model context.
    public func get<T>(_ model: Model<T>) throws -> T? {
        guard let item = try self.getOptional(model) else { throw QueryError.itemNotFound(.model(model)) }
        return item
    }
    
    /// Retrieves an optional persistent mode from this model context.
    ///
    /// - Parameters:
    ///     - selector: the query criteria used to fetch the persistent model.
    ///
    /// - Returns: the requested peristsent model.
    ///
    /// - Throws:  a `QuerryError.itemNotFound` if the requested model could not be found in this model context.
    public func getOptional<PersistentModelType>(_ selector: Selector<PersistentModelType>.Get) throws -> PersistentModelType? {
        let peristentModel: PersistentModelType?
        
        switch selector {
        case .model(let model):
            peristentModel = try self.getOptional(model)
        case .predicate(let predicate):
            peristentModel = try self.first(where: predicate)
        }
        
        return peristentModel
    }
    
    /// Retrieves and transforms an optional persistent model his model context..
    ///
    /// - Parameters:
    ///     - selector: the query criteria used to fetch the persistent model.
    ///     - completion: a closure that produces a type `T` from the given optional persistent model.
    ///
    /// - Returns: the result of the completion closure.
    ///
    /// - Throws:  a `QuerryError.itemNotFound` if the requested model could not be found in this model context.
    public func getOptional<PersistentModelType, T: Sendable>(for selector: Selector<PersistentModelType>.Get, with completion: @escaping @Sendable (PersistentModelType?) throws -> T) throws -> T {
        let peristentModel: PersistentModelType?
        
        switch selector {
        case .model(let model):
            peristentModel = try self.getOptional(model)
        case .predicate(let predicate):
            peristentModel = try self.first(where: predicate)
        }
        
        return try completion(peristentModel)
    }
    
    /// Retrieves a collection of persistent models from this model context.
    ///
    /// - Parameters:
    ///     - selectors: the query criteria for each model to fetch.
    ///
    /// - Returns: an array of persistent models.
    ///
    /// - Throws: a `QuerryError.itemNotFound` if a requested model could not be found in this model context.
    public func fetch<PersistentModelType>(for selectors: [Selector<PersistentModelType>.Get]) throws -> [PersistentModelType] {
        try selectors.map { try self.getOptional($0) }.compactMap { $0 }
    }
    
    /// Retrieves and transforms collection of persistent models from this model context.
    ///
    /// - Parameters:
    ///     - selector: the query criteria used to retrieve the requested models.
    ///     - completion: a closure that produces a single type `T` from a given array of persistent models.
    ///
    /// - Returns: the result of the completion closure.
    ///
    /// - Throws: any errors thrown by the completion closure.
    public func fetch<PersistentModelType, T: Sendable>(for selector: Selector<PersistentModelType>.List, with completion: @escaping @Sendable ([PersistentModelType]) throws -> T) throws -> T {
        let persistentModels: [PersistentModelType]
        switch selector { case .descriptor(let descriptor): persistentModels = try self.fetch(descriptor) }
        return try completion(persistentModels)
    }
    
    /// Deletes a persistent model from this model context.
    ///
    /// - Parameter selector: the query criteria that defines the model to delete.
    ///
    /// - Throws:  a SwiftData error describing why the specified model could not be removed from this context.
    public func delete<PersistentModelType>(_ selector: Selector<PersistentModelType>.Delete) throws {
        switch selector {
        case .predicate(let predicate):
            try self.delete(model: PersistentModelType.self, where: predicate)
        case .model(let model):
            if let persistentModel = try self.getOptional(model) { self.delete(persistentModel) }
        case .all:
            try self.delete(model: PersistentModelType.self)
        }
    }
    
    /// Deletes all persistent models specifed by the given selectors.
    ///
    /// - Parameter selectors: an array of selector delete operations.
    ///
    /// - Throws: a SwiftData error describing why a given model could not be removed from this context.
    public func delete<PersistentModelType>(_ selectors: [Selector<PersistentModelType>.Delete]) throws {
        for selector in selectors { try self.delete(selector) }
    }
    
}

