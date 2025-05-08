//
//  YomuTests.swift
//  YomuTests
//
//  Created by Andrew Joe on 2024-09-30.
//

import Foundation
import Testing
@testable import Yomu

private extension Bundle {
    /// Same debug bundle decoding used to test custom decoding implemenations.
    ///
    /// This function will cause a fatal error, if the specficied file cannot be found, or
    /// is unable to decode the bundled data.
    ///
    /// - Parameter file: The name of the file to decode in the bundle.
    ///
    /// - Returns: The decoded data.
    ///
    /// - Throws: A decoding error if the requested file cannot be decoded.
    func testDecoding<T: Decodable>(from file: String) throws -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else { fatalError("Failed to locate \(file) in bundle.") }
        guard let data = try? Data(contentsOf: url) else { fatalError("Failed to load \(file) from bundle.") }
        return try JSONDecoder().decode(T.self, from: data)
      
    }
}

/// A collection of units tests for this apps "business logic".
///
struct YomuTests {
    /// Basic unit tests for decode the types defined in Models.
    ///
    /// - Note: The AtHomeChapterComponents type is intentionally excluded as MangaDex as they expire after fifteen minutes,
    ///         and having components in the bundle could allow for the construction of URLs that
    @Suite("Decoding Tests") struct YomuDecodingTests {
        /// Tests decoding the bundled author JSON data.
        ///
        /// Checks for successful decoding of an author's manga [reference expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/).
        @Test("Decode Author from Namori.json")
        func canDecodeAuthor() {
            #expect(throws: Never.self) {
                let author: Wrapper<Author> = try Bundle.main.testDecoding(from: "Namori.json")
                #expect(author.data.name == "Namori")
                #expect(author.data.type == "author")
                #expect(author.data.relatedManga?.isEmpty == false)
            }
        }
        
        /// Tests decoding the bundled chapter JSON data.
        ///
        /// Check for successful decoding of a chapter's scanlation group and manga [reference expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/).
        @Test("Decode Chapter from Laid Back Camp Ch. 1 - Mt.Fuji and Cup Ramen.json")
        func canDecodeChapter() {
            #expect(throws: Never.self) {
                let chapter: Wrapper<Chapter> = try Bundle.main.testDecoding(from: "Laid Back Camp Ch. 1 - Mt. Fuji and Cup Ramen.json")
                #expect(chapter.data.title == "Mt. Fuji and Cup Ramen")
                #expect(chapter.data.scanlationGroup?.name == "SiberOwl")
                #expect(chapter.data.parentManga?.title?["en"] == "Yuru Camp△")
            }
        }
        
        /// Tests decoding the bundled cover JSON data.
        ///
        /// Since the easiest way to get a cover's JSON data its through a manga's  [reference expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/)
        /// this test is mostly to ensure that the nested cover is decoded correctly.
        @Test("Decode Cover from Koi yori Aoku Volume 3 Cover.json")
        func canDecodeCover() {
            #expect(throws: Never.self) {
                let cover: Wrapper<Cover> = try Bundle.main.testDecoding(from: "Koi yori Aoku Volume 3 Cover.json")
                #expect(cover.data.fileName == "321be56f-56a2-43c4-a985-43a7d6b86a37.png")
                #expect(cover.data.locale == "ja")
            }
        }
        
        /// Tests decoding the bundled manga JSON data.
        ///
        /// Checks for successful decoding of an manga''s author/artist, related manga, and cover [reference expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/).
        @Test("Decode Manga from I Can't Say No to the Lonely Girl.json")
        func canDecodeManga() {
            #expect(throws: Never.self) {
                let manga: Wrapper<Manga> = try Bundle.main.testDecoding(from: "I Can't Say No to the Lonely Girl.json")
                #expect(manga.data.title["en"] == "I Can't Say No to the Lonely Girl")
                #expect(manga.data.altTitles.first(where: { $0.keys.count == 1 && $0.first?.key == "en" })?["en"] == "Can't Defy The Lonely Girl")
                #expect(manga.data.author.first?.name == "Kashikaze")
                #expect(manga.data.cover.volume == "6")
                #expect(manga.data.relatedManga != nil)
            }
        }
        
        /// Tests decoding the bundled scanlation group JSON data.
        ///
        /// Checks for successful decoding of all scanlation group members [reference expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/).
        @Test("Decode ScanlationGroup from Sho Habby Scans.json")
        func canDecodeScanlationGroup() {
            #expect(throws: Never.self) {
                let scanlationGroup: Wrapper<ScanlationGroup> = try Bundle.main.testDecoding(from: "Sho Habby Scans.json")
                #expect(scanlationGroup.data.name == "Sho Habby Scans")
                #expect(scanlationGroup.data.relationships?.isEmpty == false)
            }
        }
        
        /// Tests that chapter statistics can be dynamicaly decoded based on the UUID key found through the "statistics" keypath.
        ///
        /// - Parameter file: The name of the file to be decoded in the bundle.
        @Test("Decode Chapter Statistics", arguments: ["Isekai Izakaya Chapter 1 Statistics.json", "Shinya Shokudou Chapter 1 Statistics.json"])
        func canDecodeChapterStatisics(_ file: String) {
            #expect(throws: Never.self) {
                let chapter: StatisticsWrapper<ChapterStatistics> = try Bundle.main.testDecoding(from: file)
                #expect(chapter.statistics.threadId == 36327 || chapter.statistics.threadId == 483615)
                #expect(chapter.statistics.repliesCount == 9 || chapter.statistics.repliesCount == 3)
            }
        }
        
        /// Tests that manga statistics can be dynamicaly decoded based on the UUID key found through the "statistics" keypath.
        ///
        /// - Parameter file: The name of the file to be decoded in the bundle.
        @Test("Decode Manga Statistics", arguments: ["Horimiya Statistics.json", "Tensura Statistics.json"])
        func canDecodeMangaStatisics(_ file: String) {
            #expect(throws: Never.self) {
                let manga: StatisticsWrapper<MangaStatistics> = try Bundle.main.testDecoding(from: file)
                #expect(manga.statistics.threadId == 23940 || manga.statistics.threadId == 44667)
                #expect(manga.statistics.repliesCount == 590 || manga.statistics.repliesCount == 1539)
                #expect(manga.statistics.average ?? 0 >= 9 && manga.statistics.bayesian ?? 0 >= 9)
                #expect(manga.statistics.threadId != nil)
                #expect(manga.statistics.follows == 125116 || manga.statistics.follows == 205818)
            }
        }
        
        /// Tests that grouped chapter statistics can be dynamicaly based on its JSON structure.
        @Test("Decode Statistics of Multiple Chapters.")
        func canDecodeMultipleChapterStatisics() {
            #expect(throws: Never.self) {
                let chapters: GroupedStatisticsWrapper<ChapterStatistics> = try Bundle.main.testDecoding(from: "Sousou no Frieren Ch. 1 - 5 Statistics.json")
                #expect(chapters.statistics.keys.count == 5)
                #expect(chapters.statistics.values.count == 5)
            }
        }
        
        /// Tests that grouped manga statistics can be dynamicaly based on its JSON structure.
        @Test("Decode Statistics of Multiple Manga")
        func canDecodeMultipleMangaStatistics() {
            #expect(throws: Never.self) {
                let manga: GroupedStatisticsWrapper<MangaStatistics> = try Bundle.main.testDecoding(from: "Grouped Manga Statistics.json")
                #expect(manga.statistics.keys.count == 2)
                #expect(manga.statistics.values.count == 2)
            }
        }
        
        @Test("Decode User form User.json")
        func canDecodeUser() {
            #expect(throws: Never.self) {
                let user: Wrapper<User> = try Bundle.main.testDecoding(from: "User.json")
                #expect(user.data.username == "ripe-mango")
                #expect(user.data.roles ==  ["ROLE_GROUP_LEADER", "ROLE_GROUP_MEMBER", "ROLE_USER"])
                #expect(user.data.relationships.count == 1)
            }
        }
    }
}


