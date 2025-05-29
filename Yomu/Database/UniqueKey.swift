//
//  UniqueKey.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-24.
//

import Foundation

/// Similar to Indetifiable, Unique types cannot have duplicates.
public protocol Unique {
    /// A type representing the unique keys for the conforming type.
    associatedtype Keys: UniqueKeys<Self>
}

/// Unique keys are used to define key paths for a model, and asscoaited value.
public protocol UniqueKey: Sendable {
    /// The model associated with this key.
    associatedtype Model: Unique
    
    /// The value associated with this unique key.
    associatedtype ValueType: Sendable & Equatable & Codable
    
//    func predicate(equals value: ValueType) -> Predicate<Model>
}

/// A type that represents all keys for a Unique type.
public protocol UniqueKeys<Model>: Sendable {
    /// The type that defines this set of unique keys.
    associatedtype Model: Unique
    
    /// The unique key that will be used as the primary key for a Model.
    associatedtype PrimaryKey: UniqueKey where PrimaryKey.Model == Model
    
    /// The primary key of a model type.
    static var primary: PrimaryKey { get }
}

extension UniqueKeys {
    /// Creates a unique key path for a given key path.
    ///
    /// - Parameter keyPath: The key path of a Model.
    ///
    /// - Returns: a newly created unique key path.
    public static func keyPath<ValueType: Sendable & Equatable & Codable>(_ keyPath: any KeyPath<Model, ValueType> & Sendable) -> UniqueKeyPath<Model, ValueType> {
        return UniqueKeyPath(keyPath: keyPath)
    }
}

/// A unique key path for a Model.
public struct UniqueKeyPath<Model: Unique, ValueType: Sendable & Equatable & Codable>: UniqueKey {
    /// The key path of a Model type.
    private let keyPath: KeyPath<Model, ValueType> & Sendable
    
    /// Creates a new unique key path with the given key path.
    ///
    /// - Parameter keyPath: the key path of a Model.
    ///
    /// - Returns: a newly created unqiue key path.
    internal init(keyPath: any KeyPath<Model, ValueType> & Sendable) {
        self.keyPath = keyPath
    }
    
//    I have no idea what is actually supossed to happen here, it should return a prediacte for used in a @Query macro for a generic Model, but it takes in a generic type and then supossedly returns the predicated comparing the ValueType to the value through KeyPath with a root of Model.
//    public func predicate(equals value: ValueType) -> Predicate<Model> {
//        #Predicate<Model> { model in
//            model[keyPath: keyPath] == value
//        }
//    }
}
