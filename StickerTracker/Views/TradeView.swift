import SwiftUI
import SwiftData

private enum TradeMode: String, CaseIterable {
    case friendMissing = "Their missing"
    case friendDuplicates = "Their duplicates"
}

struct TradeView: View {
    @Query(sort: \Team.sortOrder) private var teams: [Team]
    @State private var pastedText = ""
    @State private var tradeMode: TradeMode = .friendMissing
    @FocusState private var isEditing: Bool

    private var parsedStickers: [String: Set<Int>] { parseInput(pastedText) }

    private var canGive: [(team: Team, numbers: [Int])] {
        teams.compactMap { team in
            guard let friendNeeds = parsedStickers[team.code] else { return nil }
            let numbers = team.stickers
                .filter { friendNeeds.contains($0.number) && $0.duplicateCount > 0 }
                .map(\.number).sorted()
            return numbers.isEmpty ? nil : (team, numbers)
        }
    }

    private var canReceive: [(team: Team, numbers: [Int])] {
        teams.compactMap { team in
            guard let friendHas = parsedStickers[team.code] else { return nil }
            let numbers = team.stickers
                .filter { friendHas.contains($0.number) && !$0.isCollected }
                .map(\.number).sorted()
            return numbers.isEmpty ? nil : (team, numbers)
        }
    }

    private var canGiveCount: Int { canGive.reduce(0) { $0 + $1.numbers.count } }
    private var canReceiveCount: Int { canReceive.reduce(0) { $0 + $1.numbers.count } }

    private var tradeShareText: String {
        let results = tradeMode == .friendMissing ? canGive : canReceive
        guard !results.isEmpty else { return "" }
        let header = tradeMode == .friendMissing ? "You can give:" : "You can get:"
        let lines = results.map { "\($0.team.flagEmoji) \($0.team.code): \($0.numbers.map(String.init).joined(separator: " "))" }
        return ([header] + lines).joined(separator: "\n")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    pasteSection
                    if !pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        let results = tradeMode == .friendMissing ? canGive : canReceive
                        if results.isEmpty {
                            ContentUnavailableView(
                                "No matches",
                                systemImage: "arrow.left.arrow.right",
                                description: Text("No stickers to trade with this list.")
                            )
                            .padding(.top, 32)
                        } else {
                            let title = tradeMode == .friendMissing ? "You can give" : "You can get"
                            let color: Color = tradeMode == .friendMissing ? .green : .blue
                            let count = tradeMode == .friendMissing ? canGiveCount : canReceiveCount
                            TradeSection(title: title, count: count, items: results, color: color)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Trade")
            .onTapGesture { isEditing = false }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: tradeShareText) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(tradeShareText.isEmpty)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isEditing = false }
                }
            }
        }
    }

    private var pasteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Mode", selection: $tradeMode) {
                Text(parsedStickers.isEmpty ? "Their missing" : "Their missing (\(canGiveCount))")
                    .tag(TradeMode.friendMissing)
                Text(parsedStickers.isEmpty ? "Their duplicates" : "Their duplicates (\(canReceiveCount))")
                    .tag(TradeMode.friendDuplicates)
            }
            .pickerStyle(.segmented)
            .onChange(of: tradeMode) { pastedText = "" }

            HStack {
                Text(tradeMode == .friendMissing ? "Paste friend's missing list" : "Paste friend's duplicate list")
                    .font(.headline)
                Spacer()
                if !pastedText.isEmpty {
                    Button("Clear") { pastedText = "" }
                        .font(.subheadline)
                }
            }
            ZStack(alignment: .topLeading) {
                if pastedText.isEmpty {
                    Text("e.g. 🇺🇸 USA: 1 2 3\n🇧🇷 BRA 5 7 9\nPAN: 1(1x), 20(2x)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 12)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $pastedText)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .focused($isEditing)
            }
            .padding(8)
            .background(Color(.systemGray6))
            .clipShape(.rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
            )
        }
    }

    // Handles formats:
    // "🇺🇸 USA: 1 2 3", "USA: 1, 2, 3", "USA 1 2 3", "usa:1,2,3"
    // "PAN: 1(1x), 20(2x)" — number(countx) means sticker held multiple times
    private func parseInput(_ text: String) -> [String: Set<Int>] {
        // Matches "5(2x)" style — capture the sticker number before the paren
        let multiplierPattern = /(\d+)\(\d+x\)/
        var result: [String: Set<Int>] = [:]
        for line in text.components(separatedBy: .newlines) {
            let upper = line.uppercased()
            guard let team = teams.first(where: { upper.contains($0.code) }),
                  let range = upper.range(of: team.code) else { continue }
            var tail = String(upper[range.upperBound...])
            let validNumbers = Set(team.stickers.map(\.number))
            var numbers = Set<Int>()
            // Extract "NUMBER(Nx)" patterns first so the inner count digit isn't parsed as a sticker
            for match in tail.matches(of: multiplierPattern) {
                if let n = Int(match.output.1), validNumbers.contains(n) {
                    numbers.insert(n)
                }
            }
            tail = tail.replacing(multiplierPattern, with: "")
            // Parse remaining plain numbers
            numbers.formUnion(
                tail.components(separatedBy: CharacterSet.decimalDigits.inverted)
                    .compactMap(Int.init)
                    .filter { validNumbers.contains($0) }
            )
            guard !numbers.isEmpty else { continue }
            result[team.code, default: []].formUnion(numbers)
        }
        return result
    }
}

private struct TradeSection: View {
    let title: String
    let count: Int
    let items: [(team: Team, numbers: [Int])]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(count) total")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(color)
            }
            ForEach(items, id: \.team.id) { item in
                HStack(alignment: .top, spacing: 10) {
                    Text(item.team.flagEmoji)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.team.code)
                            .font(.subheadline.weight(.semibold))
                        Text(item.numbers.map(String.init).joined(separator: "  "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(item.numbers.count)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(color)
                }
            }
        }
        .padding()
        .background(color.opacity(0.08))
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
    }
}
