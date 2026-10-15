/// The time slots an activity chart groups messages by.
nonisolated enum ActivityAxis: String, CaseIterable, Identifiable, Sendable {
    case hour
    case weekday
    case month
    case year

    var id: Self { self }
}
