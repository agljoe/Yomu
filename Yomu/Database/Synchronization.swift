//
//  Synchronization.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-27.
//

import Foundation
import SwiftData

/// A de-sync between a persistent model, and some data.
public protocol SynchronizationDifference {
    /// The model type of a persistent model.
    associatedtype PersistentModelType: PersistentModel
    
    /// A type of data that can safely be passed across thread.
    associatedtype DataType: Sendable
    
    /// Compares the synchronization of a persistent model and the given data.
    ///
    /// - Parameters:
    ///     - persistentModel: a class managed as a stored model.
    ///     - data: a sendable type, being synchronized.
    ///
    /// - Returns: the synchronization difference between a peristent model and some data.
    static func compare(_ persistentModel: PersistentModelType, with data: DataType) -> Self
}

/// A type that can update a persistent model such that its stored properites are synchronized with some data.
public protocol ModelSynchronizer {
    /// The actual type of a persistent model.
    associatedtype PersistentModelType: PersistentModel
    
    /// A type of data that can safely be passed across thread.
    associatedtype DataType: Sendable
    
    /// Synchronizes a persistent model with the passed data, in a given database.
    ///
    /// - Parameters:
    ///     - model: a class managed as a stored model, wrapped as a `Model` type.
    ///     - data: a sendable type, being synchronized.
    ///     - database: the database in which the sychronization will occur.
    ///
    /// - Throws: any errors that occur during synchronization.
    static func synchronize(_ model: Model<PersistentModelType>, with data: DataType, using database: any Database) async throws
}

/// A wrapper around a managed model class, and some thread safe data.
private struct SynchronizationUpdate<PersistentModelType: PersistentModel, DataType: Sendable> {
    /// Some data that is being used to update a peristent model.
    var file: DataType?
    
    /// A stored model class that is being synchronized with the data type.
    var entry: PersistentModelType?
}

/// 
public protocol CollectionSynchronizer {
    ///
    associatedtype PersistentModelType: PersistentModel
    associatedtype DataType: Sendable
    associatedtype ID: Hashable
    
    static var dataKey: KeyPath<DataType, ID> { get }
    
    static func getSelector(from data: DataType) -> Selector<PersistentModelType>.Get
    
    static func persistentModel(from data: DataType) -> PersistentModelType
    
    static func synchronize(_ persistentModel: PersistentModelType, with data: DataType) throws
}
