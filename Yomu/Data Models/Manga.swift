//
//  Manga.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-05.
//

import Foundation

struct Manga: Codable, Identifiable { //needs comments, art and related tabs(?)
    let id: String
    let title: String //should be localized for mangadex localization // todo: add localization dictionary w/ flags
    let cover: URL // change to Cover - make struct for
    let description: String? // should be localized
    
    let author: String? //should be localized for mangadex localization
    let aritst: String? //should be localized for mangadex localization
    let authors: [String]?
    let aritists: [String]?
    
    let genres: [String]
    let format: [String]?
    let demographic: String?
    
    let sources: URL // should be a Source - make struct for source
    let trackers: [URL]? // should be Tracker - make struct for tracker
    
    let alternateTitles: [String]? // make sure we can handle all languages
    
    let finalChapter: String?
    
    
}
