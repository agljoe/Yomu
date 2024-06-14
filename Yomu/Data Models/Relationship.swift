//
//  Relationship.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-11.
//

import Foundation

struct Relationship: Codable, Identifiable {
    let id: UUID
    let type: RelationshipType
    let related: MangaRelated?
}

