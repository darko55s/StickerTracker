import SwiftUI
import SwiftData

struct DuplicatesView: View {
    @Query(sort: \Team.sortOrder) private var teams: [Team]
    @Query private var stickers: [Sticker]  // drives reactivity when duplicateCount changes
    @State private var navigateToAdd = false
    @State private var searchText = ""
    @State private var isSelecting = false
    @State private var selectedIDs = Set<Sticker.ID>()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

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
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(teamsWithDuplicates) { team in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("\(team.flagEmoji) \(team.name)")
                                        .font(.headline)
                                        .padding(.horizontal)

                                    LazyVGrid(columns: columns, spacing: 8) {
                                        ForEach(
                                            team.stickers
                                                .filter { $0.duplicateCount > 0 }
                                                .sorted { $0.number < $1.number }
                                        ) { sticker in
                                            duplicateTile(sticker: sticker)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
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

    @ViewBuilder
    private func duplicateTile(sticker: Sticker) -> some View {
        let isSelected = selectedIDs.contains(sticker.id)
        ZStack {
            StickerTile(sticker: sticker)
                .allowsHitTesting(false)

            if isSelecting {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.25) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        if isSelected {
                            selectedIDs.remove(sticker.id)
                        } else {
                            selectedIDs.insert(sticker.id)
                        }
                    }
            }
        }
    }
}
