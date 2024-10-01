//
//  YomuTests.swift
//  YomuTests
//
//  Created by Andrew Joe on 2024-09-30.
//

import Testing
@testable import Yomu

struct YomuTests {
    // Since data from the MangaDexAPI is always subject to change just check for api and decoding errors
    // Check urls if tests fail
    struct YomuRequestTests {
        
        @Test("Test for api heath")
        func testHealthCheck() async {
           
        }

        @Test("Test successfully getting and decoding of manga json data")
        func testGetManga() async { //https://mangadex.org/title/8b58f452-4d8a-4aad-a050-349e83fecccb/jujutsu-kaisen-0
            await #expect(throws: Never.self) {
                _ = try await getManga(id: "8b58f452-4d8a-4aad-a050-349e83fecccb")
            }
        }
        
        @Test("Test that getting a manga with an invalid id throws the correct error")
        func testGetMangaWithInvalidId() async {
            await #expect(throws: Request.MDApiError.notFound) {
               _ = try await getManga(id: "invalid-id")
            }
        }
        
        @Test("Test successfully getting and decoding of chapter json data")
        func testGetChapter() async {
            await #expect(throws: Never.self) { //https://mangadex.org/chapter/679b32f1-2ec4-466e-ac06-51b80289bf4d
                _ = try await getChapter(id: "679b32f1-2ec4-466e-ac06-51b80289bf4d")
            }
        }
        
        @Test("Test that getting a chapter with an invalid id throws the correct error")
        func testGetChapterWithInvalidID() async {
            await #expect(throws: Request.MDApiError.notFound) {
                _ = try await getChapter(id: "invalid-id")
            }
        }
        
        @Test("Test successful getting and decoding of a cover url")
        func testGetCover() async {
            await #expect(throws: Never.self) { //https://mangadex.org/covers/b0b721ff-c388-4486-aa0f-c2b0bb321512/f812f3d4-f1df-40ce-bd3c-dcc0fd0eb17b.jpg and https://mangadex.org/covers/8f3e1818-a015-491d-bd81-3addc4d7d56a/2a0f3da4-e983-44df-b7d5-5ff67f678cf8.jpg
                _ = try await getCoversFor(ids: ["8f3e1818-a015-491d-bd81-3addc4d7d56a", "b0b721ff-c388-4486-aa0f-c2b0bb321512"])
            }
        }
    }
    
    struct YomuAuthenticationTests {
        
    }
}


