import SwiftUI
import SwiftData

struct TeamDetailView: View {
    @Query(sort: \Team.sortOrder) private var teams: [Team]
    @State private var currentTeam: Team

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    init(team: Team) {
        _currentTeam = State(initialValue: team)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryBar
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(currentTeam.stickers.sorted(by: { $0.number < $1.number })) { sticker in
                        StickerTile(sticker: sticker)
                    }
                }
                .padding(.horizontal)

                HStack {
                    Button {
                        navigateToTeam(offset: -1)
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(canNavigate(offset: -1) ? .blue : .secondary.opacity(0.3))
                    }
                    .disabled(!canNavigate(offset: -1))

                    Spacer()

                    Button {
                        navigateToTeam(offset: 1)
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(canNavigate(offset: 1) ? .blue : .secondary.opacity(0.3))
                    }
                    .disabled(!canNavigate(offset: 1))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
            }
            .padding(.top, 8)
        }
        .navigationTitle("\(currentTeam.flagEmoji) \(currentTeam.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: missingStickersText) {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(missingStickersText.isEmpty)
            }
        }
    }

    private func navigateToTeam(offset: Int) {
        guard let index = teams.firstIndex(where: { $0.id == currentTeam.id }) else { return }
        let newIndex = index + offset
        guard teams.indices.contains(newIndex) else { return }
        currentTeam = teams[newIndex]
    }

    private func canNavigate(offset: Int) -> Bool {
        guard let index = teams.firstIndex(where: { $0.id == currentTeam.id }) else { return false }
        return teams.indices.contains(index + offset)
    }

    private var missingStickersText: String {
        let missing = currentTeam.stickers
            .filter { !$0.isCollected }
            .sorted { $0.number < $1.number }
            .map { String($0.number) }
            .joined(separator: " ")
        guard !missing.isEmpty else { return "" }
        return "\(currentTeam.code): \(missing)"
    }

    private var summaryBar: some View {
        VStack(spacing: 6) {
            HStack {
                Text("\(currentTeam.collectedCount) / \(currentTeam.totalCount) collected")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(currentTeam.totalCount - currentTeam.collectedCount) missing")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: currentTeam.progress)
                .tint(currentTeam.progress == 1.0 ? .green : .blue)
        }
        .padding(.horizontal)
    }
}
