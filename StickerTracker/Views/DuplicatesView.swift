import SwiftUI
import SwiftData

struct DuplicatesView: View {
    @Query(sort: \Team.sortOrder) private var teams: [Team]
    @Query private var stickers: [Sticker]  // drives reactivity when duplicateCount changes
    @State private var navigateToAdd = false
    @State private var searchText = ""
    @State private var isSelecting = false
    @State private var selectedIDs = Set<Sticker.ID>()

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

    private func removeSelected() {
        for team in teamsWithDuplicates {
            for sticker in team.stickers where selectedIDs.contains(sticker.id) {
                sticker.duplicateCount = 0
            }
        }
        selectedIDs.removeAll()
        isSelecting = false
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
                    List(selection: $selectedIDs) {
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
                                    .tag(sticker.id)
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
                    .environment(\.editMode, .constant(isSelecting ? .active : .inactive))
                }
            }
            .navigationTitle("Duplicates")
            .searchable(text: $searchText, prompt: "Team name, code or sticker…")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if isSelecting {
                        Button("Remove", role: .destructive) { removeSelected() }
                            .disabled(selectedIDs.isEmpty)
                    } else {
                        ShareLink(item: duplicatesShareText) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .disabled(duplicatesShareText.isEmpty)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isSelecting {
                        Button("Done") {
                            isSelecting = false
                            selectedIDs.removeAll()
                        }
                    } else {
                        HStack {
                            Button("Select") { isSelecting = true }
                            Button("Add") { navigateToAdd = true }
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToAdd) {
                AddDuplicateView()
            }
        }
    }
}
