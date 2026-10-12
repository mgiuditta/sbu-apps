/// The Serie of a habit and the Serie piena of all of them, counted in logical days.
///
/// Today not done yet never breaks a streak: the day is not over. Days with nothing expected
/// are neutral: they neither break a streak nor add to it.
nonisolated enum Streak {
    private enum Day {
        case done, neutral, missed
    }

    /// Expected days in a row, up to today, on which `habit` was done.
    static func current(of habit: Habit, today: LogicalDay) -> Int {
        countBack(from: today, to: habit.createdOn) { day in
            if habit.schedule.includes(day) == false { return .neutral }
            return habit.isDone(on: day) ? .done : .missed
        }
    }

    /// Days in a row, up to today, on which every habit expected that day was done.
    static func full(of habits: [Habit], today: LogicalDay) -> Int {
        guard let firstDay = habits.map(\.createdOn).min() else { return 0 }
        return countBack(from: today, to: firstDay) { day in
            let expected = habits.filter { $0.createdOn <= day && $0.schedule.includes(day) }
            if expected.isEmpty { return .neutral }
            return expected.allSatisfy { $0.isDone(on: day) } ? .done : .missed
        }
    }

    private static func countBack(from today: LogicalDay, to firstDay: LogicalDay, result: (LogicalDay) -> Day) -> Int {
        var day = result(today) == .done ? today : today - 1
        var count = 0
        while day >= firstDay {
            switch result(day) {
            case .done: count += 1
            case .neutral: break
            case .missed: return count
            }
            day = day - 1
        }
        return count
    }
}
