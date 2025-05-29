//
//  Selector.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-05-24.
//

import Foundation
import SwiftData

extension FetchDescriptor {
    /// Creates a new fetch descriptor with the given predicate, sort, and limit.
    ///
    /// - Parameters:
    ///     - predicate: the logical condidtion used to filter a collection of models.
    ///     - sortBy: how the returned collection will be arranged.
    ///     - limit: the maximum number of items in the collection returned when using this fetch descriptor.
    ///
    /// - Returns: a newly created FetchDescriptor with
    init(predicate: Predicate<T>? = nil, sortBy: [SortDescriptor<T>] = [], fetchLimit: Int? = nil) {
        self.init(predicate: predicate, sortBy: sortBy)
        self.fetchLimit = fetchLimit
    }
}

/// A selector for database operations.
public enum Selector<T: PersistentModel>: Sendable {
    /// Represents possible cases for deleting persistent data.
    public enum Delete: Sendable {
        /// For deleting all data found by the given predicate.
        case predicate(Predicate<T>)
        
        /// For deleting a specified persistent model.
        case model(Model<T>)
        
        /// For deleting all persistent data.
        case all
    }
    
    /// Data returned by fetching with a FetchDescriptor.
    public enum List: Sendable {
        /// Fetches data using the specficed fetch descriptor.
        case descriptor(FetchDescriptor<T>)
    }
    
    /// Data returned by one to many persistent models.
    public enum Get: Sendable {
        /// Retrieve a specific persistent model.
        case model(Model<T>)
        
        /// Retrieve all persistent model that match the given predicate.
        case predicate(Predicate<T>)
    }
}

extension Selector.Get {
//    I think this where the weird predicate thing comes from, but it seems to be try to add functionality that
//    inherently doesn't that way in SwiftData.
//    public static func unique<UniqueKeyableType: UniqueKey>(
}

extension Selector.List {
    /// Creates a `Selector.List` with a custom fetch desecriptor for the specified type.
    ///
    /// - Parameters:
    ///     - type: the model type being fetched by with this descriptor.
    ///     - predicate: a logical condition used to filter a collection.
    ///     - sortBy: the sort descriptors used to arrange a collection.
    ///     - fetchLimit: the maximum number of items that can be in the returned collection.
    ///
    /// - Returns: a selector list descriptor that can be used to fetch presistent data.
    public static func decscriptor(_ type: T.Type, predicate: Predicate<T>? = nil, sortBy: [SortDescriptor<T>] = [], fetchLimit: Int? = nil) -> Selector.List {
        .descriptor(.init(predicate: predicate, sortBy: sortBy, fetchLimit: fetchLimit))
    }
    
    /// Creates a `Selector.List` with a custom fetch desecriptor.
    ///
    /// - Parameters:
    ///     - predicate: a logical condition used to filter a collection.
    ///     - sortBy: the sort descriptors used to arrange a collection.
    ///     - fetchLimit: the maximum number of items that can be in the returned collection.
    ///
    /// - Returns: a selector list descriptor that can be used to fetch presistent data.
    public static func decscriptor(predicate: Predicate<T>? = nil, sortBy: [SortDescriptor<T>] = [], fetchLimit: Int? = nil) -> Selector.List {
        .descriptor(.init(predicate: predicate, sortBy: sortBy, fetchLimit: fetchLimit))
    }
    
    /// Creates a `Selector.List` for all presistent models of the specified type.
    ///
    /// - Parameter type: a persistent model type.
    ///
    /// - Returns: a selector list that can be used to fetch all existing persistent models of the specified type.
    public static func all(_ type: T.Type) -> Selector.List {
        .descriptor(.init())
    }
    
    /// Creates a `Selector.List` for all presistent models.
    ///
    /// - Returns: a selector list that can be used to fetch all existing persistent models.
    public static func all() -> Selector.List {
        .descriptor(.init())
    }
}
