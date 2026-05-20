import SwiftUI
import SwiftData

struct DuplicateSearchResultsView: View {
    let teams: [Team]
    let searchText: String

    // "USA1" → team USA, sticker 1 that has duplicates
    private var directMatch: (team: Team, sticker: Sticker)? {
        let upper = searchText.uppercased()
        guard upper.count >= 4 else { return nil }
        let code = String(upper.prefix(3))
        let rest = String(upper.dropFirst(3))
        guard let n = Int(rest), n >= 1,
              let team = teams.first(where: { $0.code == code }),
              let sticker = team.stickers.first(where: { $0.number == n && $0.duplicateCount > 0 })
        else { return nil }
        return (team, sticker)
    }

    private var pureNumber: Int? {
        guard directMatch == nil,
              let n = Int(searchText), n >= 1 else { return nil }
        return n
    }

    // "USA" → teams matching name/code that have at least one duplicate
    private var matchingTeams: [Team] {
        guard directMatch == nil else { return [] }
        return teams.filter {
            ($0.name.localizedStandardContains(searchText) ||
             $0.code.localizedStandardContains(searchText)) &&
            $0.stickers.contains(where: { $0.duplicateCount > 0 })
        }
    }

    // Pure number → all teams that have that sticker as a duplicate
    private var allTeamDuplicates: [(team: Team, sticker: Sticker)] {
        guard let n = pureNumber else { return [] }
        return teams.compactMap { team in
            team.stickers.first(where: { $0.number == n && $0.duplicateCount > 0 }).map { (team, $0) }
        }
    }

    private var hasAnyResult: Bool {
        directMatch != nil || !matchingTeams.isEmpty || !allTeamDuplicates.isEmpty
    }

    var body: some View {
        List {
            if let match = directMatch {
                Section("\(match.team.flagEmoji) \(match.team.name) — sticker #\(match.sticker.number)") {
                    DuplicateStickerRow(team: match.team, sticker: match.sticker)
                }
            }

            if !matchingTeams.isEmpty {
                Section("Teams") {
                    ForEach(matchingTeams) { team in
                        DuplicateTeamRow(team: team)
                    }
                }
            }

            if let n = pureNumber, !allTeamDuplicates.isEmpty {
                Section("Sticker #\(n) duplicates") {
                    ForEach(allTeamDuplicates, id: \.team.id) { result in
                        DuplicateStickerRow(team: result.team, sticker: result.sticker)
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

private struct DuplicateTeamRow: View {
    let team: Team

    private var duplicateStickers: [Sticker] {
        team.stickers.filter { $0.duplicateCount > 0 }.sorted { $0.number < $1.number }
    }

    private var totalDuplicates: Int {
        duplicateStickers.reduce(0) { $0 + $1.duplicateCount }
    }

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
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(totalDuplicates) duplicate\(totalDuplicates == 1 ? "" : "s")")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                Text("\(duplicateStickers.count) sticker\(duplicateStickers.count == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct DuplicateStickerRow: View {
    let team: Team
    let sticker: Sticker

    var body: some View {
        HStack(spacing: 12) {
            Text(team.flagEmoji)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(team.name)
                    .font(.body.weight(.medium))
                Text("Sticker \(sticker.number)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("×\(sticker.duplicateCount)")
                .font(.body.weight(.semibold))
                .foregroundStyle(.orange)
                .monospacedDigit()
        }
    }
}
