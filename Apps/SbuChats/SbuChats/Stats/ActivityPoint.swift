/// One bar segment of an activity chart: how many messages a series sent in one slot.
nonisolated struct ActivityPoint: Hashable, Sendable {
    /// The slot: hour 0–23, weekday 1–7 (1 is Sunday), month as `year * 12 + month - 1`, or year.
    let slot: Int
    let series: ActivitySeries
    let count: Int
}
