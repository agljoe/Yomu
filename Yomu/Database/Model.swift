//
//  Model.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-24.
//

import CoreData
import Foundation
import SwiftData

/// Returns the child property of an object using reflection.
///
/// - Parameters:
///     - object: any object to inspect
///     - childName: the name of the child property to be retrieved.
///
/// - Returns: the child property if it exists, nil otherwise.
private func getMirrorChildValue(of object: Any, childName: String) -> Any? {
    guard let child = Mirror(reflecting: object).children.first(where: { $0.label == childName }) else {
        return nil
    }
    
    return child.value
}

extension PersistentIdentifier {
    /// A refernce to the underlying implentation,
    private var mirrorImpletetion: Any? {
        guard let implementation = getMirrorChildValue(of: self, childName: "implemenataion") else {
            assertionFailure("This value should never be nil")
            return nil
        }
        
        return implementation
    }
    
    /// Returns the managed object ID from implementation if it exsits, nil otherwise.
    private var objectID: NSManagedObjectID? {
        guard let mirrorImpletetion, let objectID = getMirrorChildValue(of: mirrorImpletetion, childName: "managedObjectID") as? NSManagedObjectID else { return nil }
        return objectID
    }
    
    /// Returns the URI representation of objectID.
    private var uriRepresentation: URL? {
        return objectID?.uriRepresentation()
    }
    
    /// Indicates if this propety should persist.
    internal var isTemporary: Bool? {
        guard let mirrorImpletetion, let isTransient = getMirrorChildValue(of: mirrorImpletetion, childName: "isTemporary") as? Bool else {
            assertionFailure("This value should never be nil.")
            return nil
        }
        
        return isTransient
    }
}

/// A phantom type for retrieving persistent models from a given model context.
public struct Model<T: PersistentModel>: Sendable, Identifiable {
    /// An error thrown when a persistent model with the given persistent identifier cannot be found.
    public struct NotFoundError: Error {
        /// The peristent identifier of the missing persistent model.
        public let persitentIdentifier: PersistentIdentifier
    }
    
    /// The persistent identifier of a persistent model.
    public let persistentIdentifier: PersistentIdentifier
    
    /// A unique indentifier for this model.
    public var id: PersistentIdentifier.ID { persistentIdentifier.id }
    
    /// Creates a new Model instance with the given persistent identifier.
    ///
    /// - Parameter persistentIdentifier: the persistent identifier for this model.
    ///
    /// - Returns: a newly created Model.
    public init(persistentIdentifier: PersistentIdentifier) {
        self.persistentIdentifier = persistentIdentifier
    }
}

extension Model where T: PersistentModel {
    /// Indicates if this model is temporary
    public var isTemporary: Bool {
        self.persistentIdentifier.isTemporary ?? false
    }
    
    /// Creates a new model instance intialized with the specified persistent model.
    ///
    /// - Parameter model: a persistent model
    ///
    /// - Returns: a newly created Model.
    public init(_ model: T) {
        self.init(persistentIdentifier: model.persistentModelID)
    }
    
    /// Creates a new Model instance with the specified persistent model.
    ///
    /// - Parameter model: a persistent model
    ///
    /// - Returns: a newly created Model if the specified model exisits, nil otherwise.
    internal static func ifMap(_ model: T?) -> Model? {
        return model.map(self.init)
    }
}
