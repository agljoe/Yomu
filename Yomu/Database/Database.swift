//
//  Database.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-23.
//

import Foundation
import SwiftData
import SwiftUI

/// Asserts the currently executing thread is the main thread if shouldAssertIsBackground.
///
/// - Parameters:
///     - isMainThread: indicates if the current thread should be the main thread.
///     - shouldAssertIsBackground: indicates if this assertion should be made.
@inlinable internal func assert(isMainThread: Bool, if shouldAssertIsBackground: Bool) {
    assert(!shouldAssertIsBackground || isMainThread == shouldAssertIsBackground)
}

/// Asserts the currently executing thread is the main thread.
///
/// - Parameter isMainThread: indicates if this is the main thread.
@inlinable internal func assert(isMainThread: Bool) {
    assert(isMainThread == Thread.isMainThread)
}

/// Indicates that an internal consistency check failed.
///
/// - Parameters:
///     - error: the error that caused this assertion failure.
///     - file: the file where this assertion failure occured.
///     - line: the line on which this assertion failure occured.
@inlinable internal func assertionFailure(error: any Error, file: StaticString = #file, line: UInt = #line) {
    assertionFailure(error.localizedDescription, file: file, line: line)
}

/// A type that can query a SwiftData model from a senable context
public protocol Database: Sendable {
    /// Executes a sendable closure on an isolated model context.
    ///
    /// - Parameter completion: the closure to exectute on the given model context.
    /// 
    /// - Returns: the value produced by the closure.
    ///
    /// - Throws: any error thrown by the passed closure.
    func withModelContext<T>(_ completion: @escaping @Sendable (ModelContext) throws -> T) async rethrows -> T
}

extension Database {
    /// Writes any pending inserts, changes, and deletes to the persistent storage.
    ///
    /// - Throws: any errors thrown when attemping to save the database's current state.
    public func save() async throws {
        try await self.withModelContext { try $0.save() }
    }
    
    /// Inserts a peristent model into the database.
    ///
    /// - Parameters:
    ///     - closure: a function that creates a persistent model
    ///     - completion: a closure that transforms the persistent model into the specified type `T`.
    ///
    /// - Returns: the result of the completion closure.
    ///
    /// - Throws: any errors throw by the completion closure.
    public func insert<PersistentModelType: PersistentModel, T: Sendable>(_ closure: @escaping @Sendable () -> PersistentModelType, with completion: @escaping @Sendable (PersistentModelType) throws -> T) async rethrows -> T {
            try await self.withModelContext { try $0.insert(closure, with: completion) }
    }
    
    
    /// Executes a transaction with this data base.
    ///
    /// - Parameter completion: a closure that performs some operation on a database.
    ///
    /// - Throws: any errors thrown during the transaction with this database's model context.
    public func transaction(_ completion: @escaping @Sendable (ModelContext) throws -> Void) async throws {
        try await self.withModelContext { context in
            try context.transaction { try completion(context) }
        }
    }
    
    /// Deletes all stored models of the specified type(s).
    ///
    /// - Parameter types: the model types to be deleted.
    ///
    /// - Throws: any errors thrown while attemping to delete the speficied model types.
    public func deteleAll(of types: [any PersistentModel.Type]) async throws {
        try await self.transaction { for type in types { try $0.delete(model: type) } }
    }
}

extension ModelActor where Self: Database {
    /// Indicates if the thread this model actor is executing on is a background thread
    public static var shouldAssertIsBackground: Bool { false }
    
    /// Executes a sendable closure on an isolated model context.
    ///
    /// - Parameter completion: the closure to exectute on the given model context.
    ///
    /// - Returns: the value produced by the closure.
    ///
    /// - Throws: any error thrown by the passed closure.
    public func withModelContext<T: Sendable>(_ completion: @escaping @Sendable (ModelContext) throws -> T) async rethrows -> T {
        assert(isMainThread: true, if: Self.shouldAssertIsBackground)
//        let modelContext = self.modelContext im pretty sure this compiles to the same thing so it doesn't really matter
        return try completion(self.modelContext)
    }
}

/// A singleton instance of a `Databse` that can be used if no database has been set for an application.
private struct DefaultDatabase: Database {
    /// The singleton instance of this database.
    static let instance = DefaultDatabase()

    func withModelContext<T>(_ completion: @escaping @Sendable (ModelContext) throws -> T) async rethrows -> T {
        assertionFailure("No database.")
        fatalError("No database.")
    }
}

extension EnvironmentValues {
    /// A database that can be used within the current environment.
    @Entry public var database: any Database = DefaultDatabase.instance
}

extension Scene {
    /// Sets the database for the current scene to given database.
    ///
    /// - Parameter database: a `Database` to be used by this scence.
    ///
    /// - Returns: A scene with an environment value of the given database.
    public func database(_ database: any Database) -> some Scene {
        environment(\.database, database)
    }
}

extension View {
    /// Sets the database for the current view to given database.
    ///
    /// - Parameter database: a `Database` to be used by this view.
    ///
    /// - Returns: A view with an environment value of the given database.
    public func database(_ database: any Database) -> some View {
        environment(\.database, database)
    }
}


