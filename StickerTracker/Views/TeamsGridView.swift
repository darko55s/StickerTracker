import SwiftUI
import SwiftData

struct TeamsGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Team.sortOrder) private var teams: [Team]
    @State private var searchText = ""

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    private var totalCollected: Int { teams.reduce(0) { $0 + $1.collectedCount } }
    private var totalStickers: Int { teams.reduce(0) { $0 + $1.totalCount } }
    private var overallProgress: Double {
        totalStickers > 0 ? Double(totalCollected) / Double(totalStickers) : 0
    }

    private var missingStickersText: String {
        teams
            .compactMap { team -> String? in
                let missing = team.stickers
                    .filter { !$0.isCollected }
                    .sorted { $0.number < $1.number }
                    .map { String($0.number) }
                    .joined(separator: " ")
                guard !missing.isEmpty else { return nil }
                return "\(team.flagEmoji) \(team.code): \(missing)"
            }
            .joined(separator: "\n\n")
    }

    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    ScrollView {
                        VStack(spacing: 16) {
                            overallSummary
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(teams) { team in
                                    NavigationLink(value: team) {
                                        TeamCard(team: team)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 8)
                    }
                } else {
                    SearchResultsView(teams: teams, searchText: searchText)
                }
            }
            .navigationTitle("FWC 2026 Stickers")
            .searchable(text: $searchText, prompt: "Team name, code or sticker number…")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: missingStickersText) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(missingStickersText.isEmpty)
                }
            }
            .navigationDestination(for: Team.self) { team in
                TeamDetailView(team: team)
            }
        }
        .onAppear {
            if teams.isEmpty {
                SeedData.seed(context: modelContext)
            }
        }
    }

    private var overallSummary: some View {
        VStack(spacing: 6) {
            HStack {
                Text("\(totalCollected) / \(totalStickers) stickers")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(overallProgress, format: .percent.precision(.fractionLength(1)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: overallProgress)
                .tint(overallProgress == 1.0 ? .green : .blue)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal)
    }
}
