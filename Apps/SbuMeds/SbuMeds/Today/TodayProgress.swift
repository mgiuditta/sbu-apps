import Foundation

/// Where today's doses stand for one person: the Closure plays when the last one is taken.
nonisolated struct TodayProgress: Equatable {
    let personID: UUID?
    let day: Day
    let toTake: Int
    let taken: Int

    init(personID: UUID?, plan: DayPlan) {
        self.personID = personID
        day = plan.day
        toTake = plan.toTakeCount
        taken = plan.takenCount
    }

    /// True when `self` follows `previous` because the last dose still to take was taken: the same
    /// person and day, doses were left and none is now, and one more is taken. A skip or the day
    /// moving on closes nothing.
    func closes(after previous: TodayProgress) -> Bool {
        personID == previous.personID && day == previous.day
            && previous.toTake > 0 && toTake == 0 && taken > previous.taken
    }
}
