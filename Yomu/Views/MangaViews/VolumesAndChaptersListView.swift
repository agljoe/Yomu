//
//  VolumesAndChaptersListView.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-02-18.
//

import Algorithms
import SwiftUI

struct Volume: Equatable {
    static func == (lhs: Volume, rhs: Volume) -> Bool {
        return lhs.number == rhs.number
    }
    
    let number: String?
    let chapters: [Chapter]
}

struct VolumesAndChaptersListView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var volumes: [Volume]
    
    var body: some View {
        ForEach(Array(volumes.enumerated()), id: \.offset) { index, volume in
            Section(header: Text(volume.number != nil ? "Vol. \(volume.number!)" : "No Volume")) {
                ForEach(volume.chapters) { chapter in
                    NavigationLink {
                        // TODO: link to external website if chapter has externalLink
                        ReaderView(chapterId: chapter.id, title: "Ch. \(chapter.chapter ?? "0") \(chapter.title ?? "")")
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack {
                            VStack(alignment: .center) {
                                Image(systemName: "eye")
                                Image(systemName: "person.3")
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Ch. \(chapter.chapter ?? "0") \(chapter.title ?? "")")
                                    .lineLimit(1)
                                Text(chapter.scanlationGroup?.name ?? "No group")
                                    .lineLimit(1)
                            }
                            .padding(.leading)
                        }
                        .foregroundStyle(colorScheme == ColorScheme.dark ? .white : .black)
                    }
                }
            }
        }
    }
}

// TODO:
func organizeChapters(_ chapters: [Chapter], _ markers: [UUID]) -> [Volume] {
    let volumes = chapters.chunked(by: { $0.volume == $1.volume })
    return volumes.map( {Volume(number: $0.first?.volume, chapters: Array($0)) })
}
