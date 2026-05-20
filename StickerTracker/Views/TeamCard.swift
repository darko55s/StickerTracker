import SwiftUI

struct TeamCard: View {
    let team: Team

    private var isComplete: Bool { team.progress == 1.0 }

    var body: some View {
        VStack(spacing: 6) {
            Text(team.flagEmoji)
                .font(.system(size: 36))

            Text(team.code)
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)

            Text(team.name)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            ProgressView(value: team.progress)
                .tint(isComplete ? .green : .blue)
                .padding(.horizontal, 4)

            Text("\(team.collectedCount)/\(team.totalCount)")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(isComplete ? .green : .secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isComplete ? Color.green.opacity(0.08) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isComplete ? Color.green.opacity(0.4) : .clear, lineWidth: 1)
        )
    }
}
