//
//  DatabaseModelActor.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-23.
//

import Foundation
import SwiftData

extension DefaultSerialModelExecutor {
    /// Creates a new model executor from the DefaultSerialExecutor.
    ///
    /// - Parameter completetion: a closure that returns a ModelContext from a given ModelContainer.
    ///
    /// - Returns: a closure that returns a ModelExecutor from a given ModelContainer
    fileprivate static func create(from completion: @escaping @Sendable (ModelContainer) -> ModelContext) -> @Sendable (ModelContainer) -> any ModelExecutor {
       return { DefaultSerialModelExecutor(modelContext: completion($0)) }
    }
}

/// A model actor that conforms to the Database protocol.
public actor DatabaseModelActor: Database, ModelActor {
    /// The model executor used by this database model actor.
    public nonisolated let modelExecutor: any SwiftData.ModelExecutor
    
    /// The model container used by this database model actor.
    public nonisolated let modelContainer: SwiftData.ModelContainer
    
    /// Creates a new DatabaseModelActor with the given model container.
    ///
    /// - Parameter modelContainer: The model container to be used by this DatabaseModelActor
    ///
    /// - Returns: a newly created DatabaseModelActor.
    public init(modelContainer: SwiftData.ModelContainer) {
        self.init(modelContainer: modelContainer, modelContext: ModelContext.init)
    }
    
    /// Creates a new DatabaseModelActor with the given model executor and container.
    ///
    /// - Parameters:
    ///      - modelExecutor: the model executor to be used by this DatabaseModelActor
    ///      - modelContainer: the model container to be used by this DatabaseModelActor
    ///
    /// - Returns: a newly created DatabaseModelActor.
    private init(modelExecutor: any ModelExecutor, modelContainer: ModelContainer) {
        self.modelExecutor = modelExecutor
        self.modelContainer = modelContainer
    }
    
    /// Creates a new DatabaseModelActor with the given model container and executor.
    ///
    /// - Parameters:
    ///     - modelContainer: the model container to be used by this DatabaseModelActor
    ///     - modelExecutor: a closure that creates a new model executor from the given model container.
    ///
    /// - Returns: a newly created DatabaseModelActor.
    public init(modelContainer: SwiftData.ModelContainer, modelExecutor completion: @escaping @Sendable (ModelContainer) -> any ModelExecutor) {
        self.init(modelExecutor: completion(modelContainer), modelContainer: modelContainer)
    }
    
    /// CreatesCreates a new DatabaseModelActor with the given model container and context.
    ///
    /// - Parameters:
    ///     - modelContainer: the model contatiner to be used by this DatabaseModelActor.
    ///     - modelContext: a closure that creates a new model context from the given model container.
    ///
    /// - Returns: a newly created DatabaseModelActor.
    public init(modelContainer: SwiftData.ModelContainer, modelContext completion: @escaping @Sendable (ModelContainer) -> ModelContext) {
        self.init(modelContainer: modelContainer, modelExecutor: DefaultSerialModelExecutor.create(from: completion))
    }
}
