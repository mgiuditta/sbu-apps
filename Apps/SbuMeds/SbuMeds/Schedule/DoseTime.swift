/// A time of day a medicine is due, with how much to take then: one tablet in the morning,
/// two in the evening.
nonisolated struct DoseTime: Hashable, Codable, Sendable, Comparable {
    static let minutesInDay = 24 * 60

    /// Minutes after midnight, local time.
    let minutes: Int
    /// How much, in the medicine's unit.
    let amount: Double

    init(minutes: Int, amount: Double = 1) {
        self.minutes = min(max(minutes, 0), Self.minutesInDay - 1)
        self.amount = amount
    }

    init(hour: Int, minute: Int = 0, amount: Double = 1) {
        self.init(minutes: hour * 60 + minute, amount: amount)
    }

    var hour: Int { minutes / 60 }
    var minute: Int { minutes % 60 }

    static func < (lhs: DoseTime, rhs: DoseTime) -> Bool {
        lhs.minutes < rhs.minutes
    }
}
