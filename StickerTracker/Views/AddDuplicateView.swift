import SwiftUI
import SwiftData

struct AddDuplicateView: View {
    @Query(sort: \Team.sortOrder) private var teams: [Team]
    @State private var selectedTeam: Team?
    @State private var selectedNumbers: Set<Int> = []

    private let teamColumns = [GridItem(.adaptive(minimum: 96), spacing: 10)]
    private let numberColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

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
                    .disabled(selectedTeam == nil || selectedNumbers.isEmpty)
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
                        selectedNumbers = []
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
                        if selectedNumbers.contains(n) {
                            selectedNumbers.remove(n)
                        } else {
                            selectedNumbers.insert(n)
                        }
                    } label: {
                        DuplicateNumberTile(
                            number: n,
                            count: duplicateCount(for: n),
                            isSelected: selectedNumbers.contains(n)
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
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
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
                .font(.title3.weight(.medium))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(.rect(cornerRadius: 10))

            if count > 0 {
                Text("\(count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(5)
                    .background(Color.orange)
                    .clipShape(Circle())
                    .offset(x: 6, y: -6)
            }
        }
        .padding(4)
    }
}
