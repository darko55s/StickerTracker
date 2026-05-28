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
    @State private var isChartExpanded = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summaryCards
                    overallProgressCard
                    teamProgressChart
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
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { isChartExpanded.toggle() }
            } label: {
                HStack {
                    Text("By Team")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isChartExpanded ? 90 : 0))
                }
                .padding(.horizontal)
            }

            if isChartExpanded {
                Chart {
                    ForEach(sortedTeams) { team in
                        BarMark(
                            x: .value("Progress", team.progress),
                            y: .value("Team", "\(team.flagEmoji) \(team.code)  \(team.collectedCount)/\(team.totalCount)")
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
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label).font(.system(size: 15))
                            }
                        }
                    }
                }
                .frame(height: CGFloat(teams.count) * 36)
                .padding(.horizontal)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical)
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
