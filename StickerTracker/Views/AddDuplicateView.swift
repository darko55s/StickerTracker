import SwiftUI
import SwiftData

struct AddDuplicateView: View {
    @Query(sort: \Team.sortOrder) private var teams: [Team]
    @State private var selectedTeam: Team?
    @State private var selectedNumber: Int?

    private let teamColumns = [GridItem(.adaptive(minimum: 72), spacing: 8)]
    private let numberColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                teamSection
                if selectedTeam != nil {
                    numberSection
                }
            }
            .padding()
        }
        .navigationTitle("Add Duplicate")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") { addDuplicate() }
                    .fontWeight(.semibold)
                    .disabled(selectedTeam == nil || selectedNumber == nil)
            }
        }
    }

    private var teamSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Team")
                .font(.headline)
            LazyVGrid(columns: teamColumns, spacing: 8) {
                ForEach(teams) { team in
                    Button {
                        if selectedTeam === team {
                            selectedTeam = nil
                        } else {
                            selectedTeam = team
                        }
                        selectedNumber = nil
                    } label: {
                        TeamChip(team: team, isSelected: selectedTeam === team)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var numberSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sticker")
                .font(.headline)
            LazyVGrid(columns: numberColumns, spacing: 8) {
                ForEach(1...(selectedTeam?.totalCount ?? 20), id: \.self) { n in
                    Button {
                        selectedNumber = selectedNumber == n ? nil : n
                    } label: {
                        DuplicateNumberTile(
                            number: n,
                            count: duplicateCount(for: n),
                            isSelected: selectedNumber == n
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func duplicateCount(for number: Int) -> Int {
        selectedTeam?.stickers.first(where: { $0.number == number })?.duplicateCount ?? 0
    }

    private func addDuplicate() {
        guard let team = selectedTeam, let number = selectedNumber else { return }
        if let sticker = team.stickers.first(where: { $0.number == number }) {
            sticker.duplicateCount += 1
        }
        selectedNumber = nil
    }
}

private struct TeamChip: View {
    let team: Team
    let isSelected: Bool

    var body: some View {
        Text("\(team.flagEmoji) \(team.code)")
            .font(.caption.weight(.medium))
            .lineLimit(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(.rect(cornerRadius: 8))
    }
}

private struct DuplicateNumberTile: View {
    let number: Int
    let count: Int
    let isSelected: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text("\(number)")
                .font(.body.weight(.medium))
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(.rect(cornerRadius: 8))

            if count > 0 {
                Text("\(count)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(Color.orange)
                    .clipShape(Circle())
                    .offset(x: 5, y: -5)
            }
        }
        .padding(3)
    }
}
