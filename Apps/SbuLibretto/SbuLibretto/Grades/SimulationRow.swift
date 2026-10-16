/// One line of the simulator: a grade for the next exam, and what the average and the base become.
nonisolated struct SimulationRow: Hashable, Identifiable, Sendable {
    let grade: Grade
    let average: Double
    /// New average minus the current one; `nil` when there is no current average.
    let change: Double?
    let base: GraduationBase

    var id: Grade { grade }
}
