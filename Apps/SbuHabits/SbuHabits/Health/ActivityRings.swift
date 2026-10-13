import Foundation

/// A day's Activity rings, as the Apple Watch keeps them: each ring closes when its value reaches
/// the goal the person set in Fitness. A ring with no goal never closes.
nonisolated struct ActivityRings: Equatable, Sendable {
    /// Calories, or minutes for a Move ring set in minutes.
    var move: Double
    var moveGoal: Double
    /// Minutes.
    var exercise: Double
    var exerciseGoal: Double
    /// Hours with at least a minute standing.
    var stand: Double
    var standGoal: Double

    /// How many rings are closed, 0 to 3.
    var closed: Int {
        [(move, moveGoal), (exercise, exerciseGoal), (stand, standGoal)]
            .count { value, goal in goal > 0 && value >= goal }
    }
}
