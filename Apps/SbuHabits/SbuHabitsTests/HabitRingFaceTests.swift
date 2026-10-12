import Testing
@testable import SbuHabits

/// The ring the app's cell and the widgets both draw.
struct HabitRingFaceTests {
    private let today = LogicalDay(ordinal: 1_004)

    private func face(timesPerDay: Int = 1, limit: Int? = nil, times: Int, skipped: Bool = false) -> HabitRingFace {
        var habit = Habit(title: "Caffè", symbol: "cup.and.saucer", timesPerDay: timesPerDay, limit: limit, createdOn: today - 5)
        habit.log[today] = times
        if skipped {
            habit.skipped.insert(today)
        }
        return HabitRingFace(habit: habit, progress: HabitProgress(of: habit, today: today, firstWeekday: 2))
    }

    @Test(arguments: [
        (1, nil as Int?, 0, "cup.and.saucer", 1, 0.0, false), // to do
        (1, nil, 1, "checkmark", 1, 1, false), // done
        (3, nil, 2, "cup.and.saucer", 3, 2, false), // two of three
        (1, 2, 0, "cup.and.saucer", 2, 2, false), // whole margin left
        (1, 2, 2, "cup.and.saucer", 2, 0, false), // at the Limite: no margin, never a checkmark
        (1, 2, 3, "xmark", 2, 2, true), // over: full, with the cross
        (1, 0, 0, "cup.and.saucer", 1, 0, false), // "never", kept
        (1, 0, 1, "xmark", 1, 1, true), // "never", given in
    ])
    func showsProgressOrMargin(timesPerDay: Int, limit: Int?, times: Int, symbol: String, segments: Int, filled: Double, isOverLimit: Bool) {
        let face = face(timesPerDay: timesPerDay, limit: limit, times: times)

        #expect(face.symbol == symbol)
        #expect(face.segments == segments)
        #expect(face.filled() == filled)
        #expect(face.isOverLimit == isOverLimit)
    }

    @Test(arguments: [
        (nil as Int?, 1, 2.0), // a hold adds one
        (nil, 3, 2), // done: a hold takes one back
        (2, 1, 0), // a hold uses up one time of the margin
        (2, 2, 0), // no margin left: stays empty
        (2, 3, 2), // over: stays full
    ])
    func aHoldMovesOneSegment(limit: Int?, times: Int, filled: Double) {
        #expect(face(timesPerDay: limit == nil ? 3 : 1, limit: limit, times: times).filled(isHolding: true) == filled)
    }

    @Test func aSkippedDayShowsTheSkipMark() {
        #expect(face(times: 0, skipped: true).symbol == "forward")
    }
}
