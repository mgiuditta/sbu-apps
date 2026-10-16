import Foundation
import SwiftData

/// A lesson in the weekly timetable: one course, one weekday, from one time to another.
@Model
final class Lesson {
    var id = UUID()
    var title = ""
    var room = ""
    /// `Calendar` weekday: 1 is Sunday, 2 Monday, up to 7 Saturday.
    var weekday = 2
    /// Minutes from midnight, 24-hour: 0 to 1439.
    var startMinutes = 9 * 60
    var endMinutes = 11 * 60
    var createdAt = Date.now

    init(title: String, room: String = "", weekday: Int, startMinutes: Int, endMinutes: Int) {
        self.title = title
        self.room = room
        self.weekday = weekday
        self.startMinutes = startMinutes
        self.endMinutes = endMinutes
    }
}
