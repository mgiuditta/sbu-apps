import Foundation
import SwiftData

/// One time a chore was done, now or on a day you picked.
@Model
final class Completion {
    var id = UUID()
    var date = Date.now
    var chore: Chore?

    init(date: Date) {
        self.date = date
    }
}
