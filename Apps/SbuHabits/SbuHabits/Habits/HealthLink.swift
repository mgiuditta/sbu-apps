/// A habit to do linked to Salute: it marks itself done on a day its measure reaches `goal`.
nonisolated struct HealthLink: Hashable, Codable, Sendable {
    var measure: HealthMeasure
    /// In the measure's unit: steps, millilitres, minutes, metres or kilocalories.
    var goal: Double

    /// Keeps `goal` within what the form offers for `measure`.
    init(measure: HealthMeasure, goal: Double) {
        self.measure = measure
        self.goal = Habit.clamp(goal, to: measure.goalRange)
    }

    /// Whether a day's `total`, in the measure's unit, reaches the goal.
    func isReached(by total: Double) -> Bool {
        total >= goal
    }
}
