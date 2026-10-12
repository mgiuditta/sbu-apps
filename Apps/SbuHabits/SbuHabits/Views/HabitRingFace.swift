import SwiftUI

/// What a habit's ring shows, shared by the app's cell and the widgets so they cannot drift:
/// the symbol, the segments, how many are filled, and whether it is over the Limite.
///
/// A habit to do fills one segment per time done, with a checkmark once done. An Abitudine da
/// evitare fills the margin left; over the Limite it turns full with a cross, drawn in `danger`,
/// so the state never rests on color alone.
nonisolated struct HabitRingFace: Equatable, Sendable {
    let symbol: String
    let segments: Int
    /// Full and in `danger`, with the cross.
    let isOverLimit: Bool
    private let progress: HabitProgress

    init(habit: Habit, progress: HabitProgress) {
        self.progress = progress
        segments = max(progress.goal, 1)
        isOverLimit = progress.isOverLimit
        symbol = if progress.isSkippedToday && habit.schedule.isWeekly == false {
            "forward"
        } else if progress.isOverLimit {
            "xmark"
        } else if progress.limit != nil {
            habit.symbol
        } else if progress.isComplete {
            "checkmark"
        } else {
            habit.symbol
        }
    }

    /// Filled segments; while holding, one segment forward, or back when the hold undoes or uses
    /// up the margin.
    func filled(isHolding: Bool = false) -> Double {
        if progress.limit != nil {
            if progress.isOverLimit { return Double(segments) }
            return Double(isHolding ? max(progress.margin - 1, 0) : progress.margin)
        }
        guard isHolding else { return Double(progress.done) }
        return Double(progress.holdUndoes ? progress.done - 1 : progress.done + 1)
    }

    /// Today's state for VoiceOver, without the Serie.
    var progressText: Text {
        if progress.isSkippedToday {
            Text("Saltata oggi")
        } else if progress.isOverLimit {
            Text("Da evitare, limite superato, \(progress.done) su \(progress.goal)")
        } else if progress.limit != nil {
            Text("Da evitare, \(progress.done) su \(progress.goal)")
        } else if progress.goal > 1 {
            Text("\(progress.done) di \(progress.goal)")
        } else {
            Text(progress.isComplete ? "Fatta" : "Da fare")
        }
    }
}
