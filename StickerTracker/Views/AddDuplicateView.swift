import SwiftUI
import SwiftData

struct AddDuplicateView: View {
    @Query(sort: \Team.sortOrder) private var teams: [Team]
    @State private var selectedTeam: Team?
    @State private var selectedNumbers: Set<Int> = []
    @State private var teamSearch = ""

    private var filteredTeams: [Team] {
        let withStickers = teams.filter { $0.stickers.contains(where: \.isCollected) }
        guard !teamSearch.isEmpty else { return withStickers }
        let query = teamSearch.uppercased()
        return withStickers.filter { $0.code.contains(query) || $0.name.uppercased().contains(query) }
    }

    private let numberColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            teamStrip
            Divider()
            if let team = selectedTeam {
                numberGrid(for: team)
            } else {
                Spacer()
                ContentUnavailableView(
                    "Select a Team",
                    systemImage: "person.3",
                    description: Text("Choose a team above to see your collected stickers.")
                )
                Spacer()
            }
        }
        .navigationTitle("Add Duplicate")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                let count = selectedNumbers.count
                Button(count > 0 ? "Add (\(count))" : "Add") { addDuplicate() }
                    .fontWeight(.semibold)
                    .disabled(selectedTeam == nil || selectedNumbers.isEmpty)
            }
        }
    }

    private var teamStrip: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search teams…", text: $teamSearch)
                    .autocorrectionDisabled()
                if !teamSearch.isEmpty {
                    Button { teamSearch = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .clipShape(.rect(cornerRadius: 10))
            .padding(.horizontal)
            .padding(.top, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(filteredTeams) { team in
                        Button {
                            if selectedTeam === team {
                                selectedTeam = nil
                            } else {
                                selectedTeam = team
                            }
                            selectedNumbers = []
                        } label: {
                            TeamChip(team: team, isSelected: selectedTeam === team)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
    }

    private func numberGrid(for team: Team) -> some View {
        let collectedNumbers = team.stickers.filter(\.isCollected).map(\.number).sorted()
        return ScrollView {
            LazyVGrid(columns: numberColumns, spacing: 8) {
                ForEach(collectedNumbers, id: \.self) { n in
                    Button {
                        if selectedNumbers.contains(n) {
                            selectedNumbers.remove(n)
                        } else {
                            selectedNumbers.insert(n)
                        }
                    } label: {
                        DuplicateNumberTile(
                            number: n,
                            count: duplicateCount(for: n, in: team),
                            isSelected: selectedNumbers.contains(n)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    private func duplicateCount(for number: Int, in team: Team) -> Int {
        team.stickers.first(where: { $0.number == number })?.duplicateCount ?? 0
    }

    private func addDuplicate() {
        guard let team = selectedTeam, !selectedNumbers.isEmpty else { return }
        for number in selectedNumbers {
            if let sticker = team.stickers.first(where: { $0.number == number }) {
                sticker.duplicateCount += 1
            }
        }
        selectedNumbers = []
    }
}

private struct TeamChip: View {
    let team: Team
    let isSelected: Bool

    var body: some View {
        Text("\(team.flagEmoji) \(team.code)")
            .font(.body.weight(.medium))
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(.rect(cornerRadius: 10))
    }
}

private struct DuplicateNumberTile: View {
    let number: Int
    let count: Int
    let isSelected: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text("\(number)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(.rect(cornerRadius: 8))

            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(Color.orange)
                    .clipShape(Circle())
                    .offset(x: 6, y: -6)
            }
        }
    }
}
