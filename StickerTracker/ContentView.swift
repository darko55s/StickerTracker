//
//  ContentView.swift
//  FifaStickers
//
//  Created by Darko Spasovski on 19/05/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            TeamsGridView()
                .tabItem {
                    Label("Collection", systemImage: "rectangle.grid.2x2")
                }
            DuplicatesView()
                .tabItem {
                    Label("Duplicates", systemImage: "doc.on.doc")
                }
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Team.self, Sticker.self], inMemory: true)
}
