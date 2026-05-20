import SwiftUI
import SwiftData

struct TeamDetailView: View {
    let team: Team

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryBar
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(team.stickers.sorted(by: { $0.number < $1.number })) { sticker in
                        StickerTile(sticker: sticker)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 8)
        }
        .navigationTitle("\(team.flagEmoji) \(team.name)")
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

    private var missingStickersText: String {
        let missing = team.stickers
            .filter { !$0.isCollected }
            .sorted { $0.number < $1.number }
            .map { String($0.number) }
            .joined(separator: " ")
        guard !missing.isEmpty else { return "" }
        return "\(team.code): \(missing)"
    }

    private var summaryBar: some View {
        VStack(spacing: 6) {
            HStack {
                Text("\(team.collectedCount) / \(team.totalCount) collected")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(team.totalCount - team.collectedCount) missing")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: team.progress)
                .tint(team.progress == 1.0 ? .green : .blue)
        }
        .padding(.horizontal)
    }


}
