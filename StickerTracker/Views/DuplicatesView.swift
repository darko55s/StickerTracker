import SwiftUI
import SwiftData

struct DuplicatesView: View {
    @Query(sort: \Team.sortOrder) private var teams: [Team]
    @Query private var stickers: [Sticker]  // drives reactivity when duplicateCount changes
    @State private var navigateToAdd = false
    @State private var searchText = ""

    private var teamsWithDuplicates: [Team] {
        teams.filter { $0.stickers.contains(where: { $0.duplicateCount > 0 }) }
    }

    private var duplicatesShareText: String {
        teamsWithDuplicates
            .compactMap { team -> String? in
                let entries = team.stickers
                    .filter { $0.duplicateCount > 0 }
                    .sorted { $0.number < $1.number }
                    .map { $0.duplicateCount > 1 ? "\($0.number)×\($0.duplicateCount)" : "\($0.number)" }
                    .joined(separator: ", ")
                return "\(team.flagEmoji) \(team.code): \(entries)"
            }
            .joined(separator: "\n")
    }

    var body: some View {
        NavigationStack {
            Group {
                if !searchText.isEmpty {
                    DuplicateSearchResultsView(teams: teams, searchText: searchText)
                } else if teamsWithDuplicates.isEmpty {
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
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button {
                                            sticker.duplicateCount -= 1
                                        } label: {
                                            Label("Remove One", systemImage: "minus.circle")
                                        }
                                        .tint(.red)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Duplicates")
            .searchable(text: $searchText, prompt: "Team name, code or sticker…")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ShareLink(item: duplicatesShareText) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(duplicatesShareText.isEmpty)
                }
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
