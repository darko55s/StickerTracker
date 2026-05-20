import SwiftUI
import SwiftData

struct StickerTile: View {
    @Environment(\.modelContext) private var modelContext
    let sticker: Sticker

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                sticker.isCollected.toggle()
            }
        } label: {
            Text("\(sticker.number)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundStyle(sticker.isCollected ? .white : .secondary)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(sticker.isCollected ? Color.green : Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(sticker.isCollected ? .clear : Color(.systemGray4), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: sticker.isCollected)
    }
}
