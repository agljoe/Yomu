//
//  CommunityView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-09.
//

import SwiftUI

struct CommunityView: View {
    var body: some View {
        // TODO: move to testing environment
        VStack {
            Text("Coming Soon")
            
            Button {
                Task {
                    do {
                        let entity = MangaEntity(id: UUID(uuidString: "9faba8cf-60df-4894-9370-22571592c8d3")!)
                        let result = try await Request<MangaEntity>(entity).execute()
                        print(result)
                    } catch let error as DecodingError {
                        handleDecodingError(error)
                    } catch { print(error.localizedDescription) }
                }
            } label: {
                Text("Test button ")
            }
            
            Button {
                Task {
                    do {
                        let result = try await getStatisticsFor(manga: [
                            UUID(uuidString: "c5d731f9-c1cf-4a69-a797-cd9c2a58316b")!,
                            UUID(uuidString: "d7576e72-0301-4ed3-9137-722ed768bfda")!
                            ])
                        print(result)
                    } catch let error as DecodingError {
                        handleDecodingError(error)
                    } catch { print(error.localizedDescription) }
                }
            } label: {
                Text("Test button 2")
            }
        }
    }
}

#Preview {
    CommunityView()
}
