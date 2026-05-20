import SwiftUI
import SwiftData

struct DuplicatesView: View {
    @Query(sort: \Team.sortOrder) private var teams: [Team]
    @Query private var stickers: [Sticker]  // drives reactivity when duplicateCount changes
    @State private var navigateToAdd = false

    private var teamsWithDuplicates: [Team] {
        teams.filter { $0.stickers.contains(where: { $0.duplicateCount > 0 }) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if teamsWithDuplicates.isEmpty {
                    ContentUnavailableView(
                        "No Duplicates",
                        systemImage: "doc.on.doc",
                        description: Text("Tap Add to record your first duplicate.")
                    )
                } else {
                    List {
                        ForEach(teamsWithDuplicates) { team in
                            Section("\(team.flagEmoji) \(team.name)") {
                                ForEach(
                                    team.stickers
                                        .filter { $0.duplicateCount > 0 }
                                        .sorted { $0.number < $1.number }
                                ) { sticker in
                                    HStack {
                                        Text("Sticker \(sticker.number)")
                                        Spacer()
                                        Text("×\(sticker.duplicateCount)")
                                            .foregroundStyle(.secondary)
                                            .monospacedDigit()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Duplicates")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") { navigateToAdd = true }
                        .fontWeight(.semibold)
                }
            }
            .navigationDestination(isPresented: $navigateToAdd) {
                AddDuplicateView()
            }
        }
    }
}
