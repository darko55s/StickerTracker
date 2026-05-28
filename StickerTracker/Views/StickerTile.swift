import SwiftUI
import SwiftData

struct StickerTile: View {
    @Environment(\.modelContext) private var modelContext
    let sticker: Sticker
    @State private var showingRemoveConfirmation = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
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

            if sticker.duplicateCount > 0 {
                Text("\(sticker.duplicateCount)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(Color.orange)
                    .clipShape(Circle())
                    .offset(x: 6, y: -6)
            }
        }
        .onLongPressGesture {
            if sticker.isCollected {
                showingRemoveConfirmation = true
            }
        }
        .onTapGesture(count: 1) {
            if !sticker.isCollected {
                sticker.isCollected = true
            } else {
                sticker.duplicateCount += 1
            }
        }
        .sensoryFeedback(.selection, trigger: sticker.isCollected)
        .sensoryFeedback(.increase, trigger: sticker.duplicateCount)
        .confirmationDialog(
            "Remove sticker \(sticker.number)?",
            isPresented: $showingRemoveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                sticker.isCollected = false
                sticker.duplicateCount = 0
            }
        }
    }
}
