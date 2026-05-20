import SwiftUI

struct SearchResultsView: View {
    let teams: [Team]
    let searchText: String

    // Parses "MAR12" / "bra1" → (team, sticker)
    private var directMatch: (team: Team, sticker: Sticker)? {
        let upper = searchText.uppercased()
        guard upper.count >= 4 else { return nil }
        let code = String(upper.prefix(3))
        let rest = String(upper.dropFirst(3))
        guard let n = Int(rest), n >= 1, n <= 20,
              let team = teams.first(where: { $0.code == code }),
              let sticker = team.stickers.first(where: { $0.number == n })
        else { return nil }
        return (team, sticker)
    }

    private var pureNumber: Int? {
        guard directMatch == nil,
              let n = Int(searchText), n >= 1, n <= 20 else { return nil }
        return n
    }

    private var matchingTeams: [Team] {
        guard directMatch == nil else { return [] }
        return teams.filter {
            $0.name.localizedStandardContains(searchText) ||
            $0.code.localizedStandardContains(searchText)
        }
    }

    private var allTeamStickers: [(team: Team, sticker: Sticker)] {
        guard let n = pureNumber else { return [] }
        return teams.compactMap { team in
            team.stickers.first(where: { $0.number == n }).map { (team, $0) }
        }
    }

    private var hasAnyResult: Bool {
        directMatch != nil || !matchingTeams.isEmpty || !allTeamStickers.isEmpty
    }

    var body: some View {
        List {
            if let match = directMatch {
                Section("\(match.team.flagEmoji) \(match.team.name) — sticker #\(match.sticker.number)") {
                    StickerSearchRow(team: match.team, sticker: match.sticker)
                }
            }

            if !matchingTeams.isEmpty {
                Section("Teams") {
                    ForEach(matchingTeams) { team in
                        NavigationLink(value: team) {
                            TeamSearchRow(team: team)
                        }
                    }
                }
            }

            if let n = pureNumber, !allTeamStickers.isEmpty {
                Section("Sticker #\(n) across all teams") {
                    ForEach(allTeamStickers, id: \.team.id) { result in
                        StickerSearchRow(team: result.team, sticker: result.sticker)
                    }
                }
            }

            if !hasAnyResult {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct TeamSearchRow: View {
    let team: Team

    var body: some View {
        HStack(spacing: 12) {
            Text(team.flagEmoji)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(team.name)
                    .font(.body.weight(.medium))
                Text(team.code)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(team.collectedCount)/\(team.totalCount)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(team.progress == 1.0 ? .green : .secondary)
        }
    }
}

private struct StickerSearchRow: View {
    let team: Team
    let sticker: Sticker

    var body: some View {
        HStack(spacing: 12) {
            Text(team.flagEmoji)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(team.name)
                    .font(.body.weight(.medium))
                Text(team.code)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    sticker.isCollected.toggle()
                }
            } label: {
                Image(systemName: sticker.isCollected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(sticker.isCollected ? .green : Color(.systemGray3))
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.selection, trigger: sticker.isCollected)
        }
    }
}
