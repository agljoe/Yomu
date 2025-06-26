//
//  CommunityView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import DataThespian
import MangaDexData
import MangaDexAPIKit
import SwiftUI

struct CommunityView: View {
    @Environment(\.database) var database
    var body: some View {
        // TODO: move to testing environment
        VStack {
            Text("Coming Soon")
            
            Button {
                print(SharedLibraryDatabase.shared.modelContainer.schema.debugDescription)
            } label: {
                Text("Print Schemas")
            }
            
            Button {
                Task {
                    let manga = await database.fetch(for: .descriptor(.init(predicate: #Predicate<PersistentManga> { $0.readingStatus != "none" }, sortBy: [SortDescriptor(\PersistentManga.title, order: .reverse)])))
                    print(manga)
                }
            } label: {
                Text("Print Library")
            }
            
            Button("Test Inserting") {
                Task {
                    do {
                        let manga = try await MangaDexAPIClient.shared.getManga(UUID(uuidString: "2e0fdb3b-632c-4f8f-a311-5b56952db647")!).get()
                        await database.insert { PersistentManga(from: manga) }
                        try await database.save()
                    } catch let error {
                        print(error)
                    }
                }
            }
             
            Button("Reset Library") {
                Task {
                    try! await database.delete(Selector<PersistentManga>.Delete.all)
                }
            }
            
            Button("Get Chapter with Expansions") {
                Task {
                    do {
                        print(try await MangaDexAPIClient.shared.getChapter(UUID(uuidString: "ff34cbc6-2c68-40f1-910a-c0e6fbd5adaf")!).get())
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

#Preview {
    CommunityView()
}
