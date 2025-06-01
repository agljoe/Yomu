//
//  Library.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-28.
//

import Foundation
import SwiftData

/// All classes marked with the @Model attribute.
private let defaultPersistentTypes: [any PersistentModel.Type] = [StoredAuthor.self, StoredChapter.self, StoredCover.self, StoredManga.self, StoredScanlationGroup.self,  StoredUser.self]

/// A singleton database that can be used across multiple views with running into trouble synchronzing mutlple model contexts.
public struct SharedLibraryDatabase : Sendable {
    /// The singleton instance of this database.
    public static let shared: SharedLibraryDatabase = .init()
    
    /// The persistent model types managed by this shared database.
    public let schemas: [any PersistentModel.Type]
    
    /// The model container for this shared database.
    public let modelContainer: ModelContainer
    
    /// The database instance for this shared database
    public let database: any Database
    
    /// Creates a new `SharedLibraryDatabase` with the given schemas, model container, and database.
    ///
    /// - Parameters:
    ///     - schemas: all the persistent models types that will be stored in this database.
    ///     - modelContainer: any object used to manage the model storage configuration.
    ///     - database: an instance of a database conforming type.
    ///
    /// - Returns: a newly created `SharedLibraryDatabase` initialized with the given parameters.
    private init(schemas: [any PersistentModel.Type] = defaultPersistentTypes, modelContainer: ModelContainer? = nil, database: (any Database)? = nil) {
        self.schemas = schemas
        let container = try! modelContainer ?? ModelContainer(for: Schema(schemas))
        self.modelContainer = container
        self.database = database ?? DatabaseModelActor(modelContainer: container)
    }
}
