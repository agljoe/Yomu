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
        
        let decoder = JSONDecoder()

        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone.current
        
        decoder.dateDecodingStrategy = .formatted(RFC3339DateFormatter)
        
        return try decoder.decode(T.self, from: data)
      
    }
}

/// Maps UUID strings for loading test data from the bundle.
private enum TestID: String {
    /// The UUID string associated with Namori.json
    case namori = "f049cee3-3b14-4101-8e5d-813526abb1f6"
    
    /// The UUID string associated with Laid Back Camp Ch. 1 - Mt. Fuji and Cup Ramen.json.
    case yuruCamp = "ff34cbc6-2c68-40f1-910a-c0e6fbd5adaf"
    
    /// The UUID string associated with Koi yori Aoku Volume 3 Cover.json
    case koiYori = "04d79fc9-f8af-422a-ae0d-0594480dce3d"
    
    /// The UUID string associated with I Can't Say No to the Lonely Girl.json.
    case lonelyGirl = "d7576e72-0301-4ed3-9137-722ed768bfda"
    
    /// The UUID string associated with Sho Habby Scans.json.
    case shoHabby = "2015e273-89af-41f6-9488-cae400463c93"
    
    /// The UUID string associated with User.json.
    case ripeMango = "c89b37ff-96e7-4196-a230-db8311316225"
}

private extension MangaDexAPIRequest {
    /// Imitates fetching data from the MangaDexAPI.
    ///
    /// - Parameter url: The URL that would be used if this were an actual request.
    ///
    /// - Returns: The model type requested by the given url.
    ///
    /// - Throws: MangaDexAPIError.notFound if the given url does not have test data.
    func mockGet(from url: URL) async throws -> ModelType {
        let id = TestID(rawValue: url.lastPathComponent)
        
        sleep(UInt32(Int.random(in: 10..<50)))
        
        switch id {
        case .namori:
            return try decode(Data(contentsOf: Bundle.main.url(forResource: "Namori.json", withExtension: nil)!))
        case .yuruCamp:
            return try decode(Data(contentsOf: Bundle.main.url(forResource: "Laid Back Camp Ch. 1 - Mt. Fuji and Cup Ramen.json", withExtension: nil)!))
        case .koiYori:
            return try decode(Data(contentsOf: Bundle.main.url(forResource: "Koi yori Aoku Volume 3 Cover.json", withExtension: nil)!))
        case .lonelyGirl:
            return try decode(Data(contentsOf: Bundle.main.url(forResource: "I Can't Say No to the Lonely Girl.json", withExtension: nil)!))
        case .shoHabby:
            return try decode(Data(contentsOf: Bundle.main.url(forResource: "Sho Habby Scans.json", withExtension: nil)!))
        case .ripeMango:
            return try decode(Data(contentsOf: Bundle.main.url(forResource: "User.json", withExtension: nil)!))
        case .none:
            throw MangaDexAPIError.notFound(context: "No mock data available for this URL.")
        }
    }
}

/// A collection of  tests for this application.
struct YomuTests {
    /// Basic unit tests for decode the types defined in Models.
    ///
    /// - Note: The AtHomeChapterComponents type is intentionally excluded as MangaDex as they expire after fifteen minutes,
    ///         and having components in the bundle could allow for the construction of URLs that
    @Suite("Decoding Tests") struct YomuDecodingTests {
        /// Tests decoding the bundled author JSON data.
        ///
        /// Checks for successful decoding of an author's manga [reference expansion](https://api.mangadex.org/docs/01-concepts/reference-expansion/).
        @Test("JSONDecoder sucessfully decodes an Author from Namori.json")
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
        @Test("JSONDecoder sucessfully decodes a chapter from Laid Back Camp Ch. 1 - Mt.Fuji and Cup Ramen.json")
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
        @Test("JSONDecoder sucessfully decodes a over from Koi yori Aoku Volume 3 Cover.json")
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
        
        /// Tests decoding the bundled user JSON data.
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
    
    /// Integration tests for fetching data from the MangaDexAPI,
    ///
    /// Uses a mock get function to ensure test isolation.
    @Suite("Mock API Tests") struct YomuAPITests {
        /// A mock generic request that fetches the entity specified by `T`.
        private struct MockRequest<T: MangaDexAPIEntity>: MangaDexAPIRequest, Sendable {
            /// The entity being retrieved by this mock request.
            let entity: T
            
            /// Creates a new request for the given entity.
            init(_ entity: T) {
                self.entity = entity
            }
            
            func decode(_ data: Data) throws -> T.ModelType {
                try JSONDecoder().decode(Wrapper<T.ModelType>.self, from: data).data
            }
            
            func execute() async throws -> T.ModelType {
                try await mockGet(from: entity.url)
            }
        }
        
        /// Tests fetching author JSON using the UUID associated with Namori.json
        @Test("Succesfully fetch an Author using a MockRequest")
        func canFetchAuthor() async {
            await #expect(throws: Never.self) {
                let entity = AuthorEntity(id: UUID(uuidString: "f049cee3-3b14-4101-8e5d-813526abb1f6")!)
                #expect(entity.url.absoluteString == "https://api.mangadex.org/author/f049cee3-3b14-4101-8e5d-813526abb1f6?includes%5B%5D=manga")
                let request = MockRequest<AuthorEntity>(entity)
                let author = try await request.execute()
                #expect(author.name == "Namori")
            }
        }
        
        /// Tests fetching chapter JSON using the UUID associated with Laid Back Camp Ch. 1 - Mt. Fuji and Curry Noodles.json
        @Test("Succesfully fetch a Chapter using a MockRequest")
        func canFetchChapter() async {
            await #expect(throws: Never.self) {
                let entity = ChapterEntity(id: UUID(uuidString: "ff34cbc6-2c68-40f1-910a-c0e6fbd5adaf")!)
                #expect(entity.url.absoluteString == "https://api.mangadex.org/chapter/ff34cbc6-2c68-40f1-910a-c0e6fbd5adaf?includes%5B%5D=manga&includes%5B%5D=scanlation_group&includes%5B%5D=user")
                let request = MockRequest<ChapterEntity>(entity)
                let chapter = try await request.execute()
                #expect(chapter.title == "Mt. Fuji and Cup Ramen")
            }
        }
        
        /// Tests fetching cover JSON using the UUID associated with Koi yori Aoku Volume 3 Cover..json
        @Test("Succesfully fetch a Cover using a MockRequest")
        func canFetchCover() async {
            await #expect(throws: Never.self) {
                let entity = CoverEntity(id: UUID(uuidString: "04d79fc9-f8af-422a-ae0d-0594480dce3d")!)
                #expect(entity.url.absoluteString == "https://api.mangadex.org/cover/04d79fc9-f8af-422a-ae0d-0594480dce3d?includes%5B%5D=manga")
                let request = MockRequest<CoverEntity>(entity)
                let cover = try await request.execute()
                #expect(cover.fileName == "321be56f-56a2-43c4-a985-43a7d6b86a37.png")
            }
        }
        
        /// Tests fetching cover JSON using the UUID associated with Sho Habby Scans.json
        @Test("Succesfully fetch a ScanlationGroup using a MockRequest")
        func canFetchScanaltionGroup() async {
            await #expect(throws: Never.self) {
                let entity = ScanlationGroupEntity(id: UUID(uuidString:"2015e273-89af-41f6-9488-cae400463c93")!)
                #expect(entity.url.absoluteString == "https://api.mangadex.org/cover/04d79fc9-f8af-422a-ae0d-0594480dce3d?includes%5B%5D=manga")
                let request = MockRequest<ScanlationGroupEntity>(entity)
                let scanlationGroup = try await request.execute()
                #expect(scanlationGroup.name == "Sho Habby Scans")
            }
        }
        
        @Test("Succesfully fetch a User using a MockRequest")
        func canFeatchUser() async {
            await #expect(throws: Never.self) {
                let entity = UserEntity(id: UUID(uuidString: "c89b37ff-96e7-4196-a230-db8311316225")!)
                #expect(entity.url.absoluteString == "https://api.mangadex.org/user/c89b37ff-96e7-4196-a230-db8311316225")
                let request = MockRequest<UserEntity>(entity)
                let user = try await request.execute()
                #expect(user.username == "ripe-mango")
            }
        }
    }
}


