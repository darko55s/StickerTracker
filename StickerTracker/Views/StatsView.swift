import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query(sort: \Team.sortOrder) private var teams: [Team]

    private var totalCollected: Int { teams.reduce(0) { $0 + $1.collectedCount } }
    private var totalStickers: Int { teams.reduce(0) { $0 + $1.totalCount } }
    private var overallProgress: Double {
        totalStickers > 0 ? Double(totalCollected) / Double(totalStickers) : 0
    }
    private var completedTeams: Int { teams.filter { $0.progress == 1.0 }.count }
    private var totalDuplicates: Int {
        teams.flatMap(\.stickers).reduce(0) { $0 + $1.duplicateCount }
    }
    private var sortedTeams: [Team] {
        teams.sorted { $0.progress > $1.progress }
    }
    private var topDuplicates: [(sticker: Sticker, team: Team)] {
        Array(
            teams.flatMap { team in
                team.stickers
                    .filter { $0.duplicateCount > 0 }
                    .map { (sticker: $0, team: team) }
            }
            .sorted { $0.sticker.duplicateCount > $1.sticker.duplicateCount }
            .prefix(10)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summaryCards
                    overallProgressCard
                    teamProgressChart
                    if !topDuplicates.isEmpty {
                        duplicatesCard
                    }
                }
                .padding()
            }
            .navigationTitle("Stats")
        }
    }

    private var summaryCards: some View {
        HStack(spacing: 12) {
            StatCard(title: "Collected", value: "\(totalCollected)", subtitle: "of \(totalStickers)")
            StatCard(title: "Complete", value: "\(completedTeams)", subtitle: "teams")
            StatCard(title: "Duplicates", value: "\(totalDuplicates)", subtitle: "total")
        }
    }

    private var overallProgressCard: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Overall Progress")
                    .font(.headline)
                Spacer()
                Text(overallProgress, format: .percent.precision(.fractionLength(1)))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: overallProgress)
                .tint(overallProgress == 1.0 ? .green : .blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var teamProgressChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Team")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(sortedTeams) { team in
                    BarMark(
                        x: .value("Progress", team.progress),
                        y: .value("Team", "\(team.flagEmoji) \(team.code)")
                    )
                    .foregroundStyle(team.progress == 1.0 ? Color.green : Color.blue)
                }
            }
            .chartXScale(domain: 0...1)
            .chartXAxis {
                AxisMarks(values: [0, 0.5, 1.0]) {
                    AxisGridLine()
                    AxisValueLabel(format: FloatingPointFormatStyle<Double>.Percent().precision(.fractionLength(0)))
                }
            }
            .frame(height: CGFloat(teams.count) * 22)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var duplicatesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Duplicates")
                .font(.headline)
            ForEach(topDuplicates, id: \.sticker.id) { item in
                HStack {
                    Text(item.team.flagEmoji)
                    Text("\(item.team.code) #\(item.sticker.number)")
                    Spacer()
                    Text("\(item.sticker.duplicateCount)×")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.orange)
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(.rect(cornerRadius: 12))
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.bold))
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(.rect(cornerRadius: 12))
    }
}
