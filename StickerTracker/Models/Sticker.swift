import Foundation
import SwiftData

@Model
final class Sticker {
    var number: Int
    var isCollected: Bool = false
    var duplicateCount: Int = 0
    var team: Team?

    init(number: Int, team: Team) {
        self.number = number
        self.team = team
    }
}
