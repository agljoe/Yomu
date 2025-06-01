//
//  BackgroundDatabase.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-28.
//

import Foundation
import SwiftData

/// A database can operate in a concurrently executing context.
public final class BackgroundDatabase: Database {
    /// An isolated instance of this background database's database.
    private actor DatabaseContainer {
        /// A function that creates a database instance.
        private let factory: @Sendable () -> any Database
        
        /// An optional unit of asynchronous work that creates a database instance and never fails.
        private var wrappedTask: Task<any Database, Never>?
        
        /// Creates a new `DatabaseContainer` instance with the given closure.
        ///
        /// - Parameter factory: a closure used to create an instance of any type that conforms to `Database`.
        ///
        /// - Returns: a newly created `DatabaseContainer`.
        fileprivate init(factory: @escaping @Sendable () -> Database) {
            self.factory = factory
        }
        
        /// The database instance isolated by this container.
        ///
        /// This value can be created asynchronously.
        fileprivate var database: any Database {
            get async {
                if let wrappedTask { return await wrappedTask.value }
                let task = Task { factory() }
                return await task.value
            }
        }
    }
    
    /// An isolated container for this background database's database.
    private let container: DatabaseContainer
    
    /// An asynchronously access instance of a database.
    private var database: any Database {
        get async { await container.database }
    }
    
    /// Creates a new `BackgroundDatabase` instance with the given closure.
    ///
    /// - Parameter factory: a closure used to create a database instance.
    ///
    /// - Returns: a newly created `BackgroundDatabase` whose database container has been initialized
    ///            with the given closure.
    public init(_ factory: @escaping @Sendable () -> any Database ) {
        self.container = .init(factory: factory)
    }
    
    /// Creates a new `BackgroundDatabase` instance with the given database.
    ///
    /// - Parameter database: a closure that creates a database.
    ///
    /// - Returns: a newly created `BackgroundDatabase` whose database instance is the result of the passed closure.
    public convenience init(database: @autoclosure @escaping @Sendable () -> any Database) {
        self.init(database)
    }
    
    public func withModelContext<T>(_ completion: @escaping @Sendable (ModelContext) throws -> T) async rethrows -> T {
        try await self.database.withModelContext(completion)
    }
}

extension BackgroundDatabase {
    /// Creates a new `BackgroundDatabase` instance with the given model container and context.
    ///
    /// - Parameters
    ///     - modelContainer: an object used to manage model storage.
    ///     - modelContext: an optional closure that creates the model context for the given model container.
    ///
    /// - Returns: a newly created `BackgroundDatabase` whose database instance a `DatabaseModelActor` initalized with the
    ///            given model container and context.
    public convenience init(modelContainer: ModelContainer, modelContext: (@Sendable (ModelContainer) -> ModelContext)? = nil) {
        self.init(database: DatabaseModelActor(modelContainer: modelContainer, modelContext: modelContext ?? ModelContext.init))
    }
    
    /// Creates a new `BackgroundDatabase` instance with the given model container.
    ///
    /// - Parameters
    ///     - modelContainer: an object used to manage model storage.
    ///
    /// - Returns: a newly created `BackgroundDatabase` whose database instance a `DatabaseModelActor` initalized with the
    ///            given model container,  and its model context.
    public convenience init(modelContainer: SwiftData.ModelContainer) {
        self.init(modelContainer: modelContainer, modelContext: ModelContext.init)
    }
    
    /// Creates a new `BackgroundDatabase` instance with the given model container.
    ///
    /// - Parameters
    ///     - modelContainer: an object used to manage model storage.
    ///     - modelExecutor: a closure that creates the model executor for the given model container.
    ///
    /// - Returns: a newly created `BackgroundDatabase` whose database instance a `DatabaseModelActor` initalized with the
    ///            given model container,  and its model executor.
    public convenience init(modelContainer: SwiftData.ModelContainer, modelExecutor: @escaping @Sendable (ModelContainer) -> any ModelExecutor) {
        self.init(database: DatabaseModelActor(modelContainer: modelContainer, modelExecutor: modelExecutor))
    }
}
