//
//  ModelContext.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-27.
//

import Foundation
import SwiftData

extension ModelContext {
    private func persistentModel<T: PersistentModel>(withID objectID: PersistentIdentifier) throws -> T? {
        if let registered: T = registeredModel(for: objectID) { return registered }
        if let notRegistered: T = model(for: objectID) as? T { return notRegistered }
        let fetchDescriptor = FetchDescriptor<T>(predicate: #Predicate { $0.persistentModelID == objectID }, fetchLimit: 1)
        return try fetch(fetchDescriptor).first
    }
    
    public func getOptional<T: PersistentModel>(_  model: Model<T>) throws -> T? {
        try self.persistentModel(withID: model.persistentIdentifier)
    }
}

extension ModelContext {
    public func first<PersistentModelType: PersistentModel>(where predicate: Predicate<PersistentModelType>? = nil) throws -> PersistentModelType? {
        try self.fetch(FetchDescriptor<PersistentModelType>(predicate: predicate, fetchLimit: 1)).first
    }
    
    public func insert<T: PersistentModel>(_ completion: @escaping @Sendable () -> T) -> Model<T> {
        let model = completion()
        self.insert(model)
        return .init(model)
    }
    
    func insert<PersistentModelType: PersistentModel, T: Sendable>(_ closure: @escaping @Sendable () -> PersistentModelType, with completion: @escaping @Sendable (PersistentModelType) throws -> T) rethrows -> T {
        let model = closure()
        self.insert(model)
        return try completion(model)
    }

    public func get<T>(_ model: Model<T>) throws -> T? {
        guard let item = try self.getOptional(model) else { throw QueryError.itemNotFound(.model(model)) }
        return item
    }
    
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
    
    public func fetch<PersistentModelType>(for selectors: [Selector<PersistentModelType>.Get]) throws -> [PersistentModelType] {
        try selectors.map { try self.getOptional($0) }.compactMap { $0 }
    }
    
    
    public func fetch<PersistentModelType, T: Sendable>(for selector: Selector<PersistentModelType>.List, with completion: @escaping @Sendable ([PersistentModelType]) throws -> T) throws -> T {
        let persistentModels: [PersistentModelType]
        switch selector { case .descriptor(let descriptor): persistentModels = try self.fetch(descriptor) }
        return try completion(persistentModels)
    }
    
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
    
    public func delete<PersistentModelType>(_ selectors: [Selector<PersistentModelType>.Delete]) throws {
        for selector in selectors { try self.delete(selector) }
    }
    
}

