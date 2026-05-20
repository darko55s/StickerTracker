import Foundation
import SwiftData

@Model
final class Team {
    @Attribute(.unique) var code: String
    var name: String
    var flagEmoji: String
    var sortOrder: Int
    @Relationship(deleteRule: .cascade, inverse: \Sticker.team)
    var stickers: [Sticker] = []

    var collectedCount: Int { stickers.filter(\.isCollected).count }
    var totalCount: Int { stickers.count }
    var progress: Double { totalCount > 0 ? Double(collectedCount) / Double(totalCount) : 0 }

    init(code: String, name: String, flagEmoji: String, sortOrder: Int) {
        self.code = code
        self.name = name
        self.flagEmoji = flagEmoji
        self.sortOrder = sortOrder
    }
}
