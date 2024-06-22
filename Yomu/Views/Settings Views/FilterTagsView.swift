//
//  FilterTagsView.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-17.
//

import SwiftData
import SwiftUI

struct TagButton: View {
    @State var buttonColor = Color.noSelection
    var body: some View {
        Button("Text") {
            switchColor(color: buttonColor)
        }
        .frame(width: 45, height: 25)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(buttonColor)
        .foregroundStyle(.buttonText)
    }
    
    func switchColor(color: Color) {
        switch color {
        case .noSelection:
            buttonColor = Color.includes
        case .includes:
            buttonColor = Color.excludes
        case .excludes:
            buttonColor = Color.noSelection
        default:
            buttonColor = Color.noSelection
        }
    }
}

struct FilterTagsView: View {
//    @Query var tags: [Tag]
    
    @State private var inclusionMode = ["And", "Or"]
    @State private var exclusionMode = ["And", "Or"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Format")) {
                    VStack {
                        HStack {
                            Spacer()
                            Button("4-Koma") {
                                
                            }
                            
                            Button("Adaptation") {
                                
                            }
                            
                            Button("Anthology") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Award Winning") {
                                
                            }
                            
                            Button("Doujinshi") {
                                
                            }
                            
                            Button("Fan Colored") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Full Color") {
                                
                            }
                            
                            Button("Long Strip") {
                                
                            }
                            
                            Button("Official Colored") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Oneshot") {
                                
                            }
                            
                            Button("Self-Published") {
                                
                            }

                            Button("Web Comic") {
                                
                            }
                            Spacer()
                        }
                    }
                }
                .textCase(.none)
                
                Section(header: Text("Genre")) {
                    VStack {
                        HStack {
                            Spacer()
                            Button("Action") {
                                
                            }
                            
                            Button("Adventure") {
                                
                            }
                            
                            
                            Button("Boy's Love") {
                                
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Comedy") {
                                
                            }
                            Button("Crime") {
                                
                            }
                            
                            Button("Drama") {
                                
                            }
                            
                            Button("Fantasy") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Girl's Love") {
                                
                            }
                            
                            Button("Historical") {
                                
                            }
                            
                            Button("Horror") {
                                
                            }
                            
                            Button("Isekai") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Magical Girls") {
                                
                            }
                            
                            Button("Mecha") {
                                
                            }
                            
                            Button("Medical") {
                                
                            }
                            
                            
                            Button("Mystery") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Philosophical") {
                                
                            }
                            
                            Button("Psycological") {
                                
                            }
                            
                            Button("Romance") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Sci-Fi") {
                                
                            }
                            
                            Button("Slice of Life") {
                                
                            }
                            
                            Button("Sports") {
                                
                            }
                            
                            Button("Superhero") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Thriller") {
                                
                            }
                            
                            Button("Tragedy") {
                                
                            }
                            
                            Button("Wuxia") {
                                
                            }
                            Spacer()
                        }
                    }
                }
                .textCase(.none)
                
                Section(header: Text("Theme")) {
                    VStack {
                        HStack {
                            Spacer()
                            Button("Aliens") {
                                
                            }
                            
                            Button("Animals") {
                                
                            }
                            
                            Button("Cooking") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Crossdressing") {
                                
                            }
                            
                            Button("Delinquents") {
                                
                            }
                            
                            Button("Demons") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Genderswap") {
                                
                            }
                            
                            Button("Ghosts") {
                                
                            }
                            
                            Button("Gyaru") {
                                
                            }
                            
                            Button("Harem") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Incest") {
                                
                            }
                            
                            Button("Loli") {
                                
                            }
                            
                            Button("Mafia") {
                                
                            }
                            
                            Button("Magic") {
                                
                            }
                            
                            Button("Marial Arts") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Military") {
                                
                            }
                            
                            Button("Monster Girls") {
                                
                            }
                            
                            Button("Monsters") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Music") {
                                
                            }
                            
                            Button("Ninja") {
                                
                            }
                            
                            Button("Office Workers") {
                                
                            }
                            
                            Button("Police") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Post-Apocalyptic") {
                                
                            }
                            
                            Button("Reincarnation") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Reverse Harem") {
                                
                            }
                            
                            Button("Samurai") {
                                
                            }
                            
                            Button("School Life") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Shota") {
                                
                            }
                            
                            Button("Supernatural") {
                                
                            }
                            
                            Button("Survival") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Time Travel") {
                                
                            }
                            
                            Button("Traditional Games") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Vampires") {
                                
                            }
                            
                            Button("Video Games") {
                                
                            }
                            
                            Button("Villainess") {
                                
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Spacer()
                            Button("Virtual Reality") {
                                
                            }
                            
                            Button("Zombies") {
                                
                            }
                            Spacer()
                        }
                    }
                }
                .textCase(.none)
                
                Section(header: Text("Content")) {
                    Button("Gore") {
                        
                    }
                    
                    Button("Sexual Violence") {
                        
                    }
                }
                .textCase(.none)
                
                Section {
                    Picker("Inclusion Mode", selection: $inclusionMode) {
                        ForEach(inclusionMode, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    
                    Picker("Exclusion Mode", selection: $exclusionMode) {
                        ForEach(exclusionMode, id: \.self) {
                            Text("\($0)")
                        }
                    }
                }
                
                Section {
                    Button("Reset Tags", role: .destructive) {
                        // remove all selections
                        // inclusion mode = AND
                        // exclusion mode = OR
                    }
                }
            }
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FilterTagsView()
}
