/// How much of a medicine is left against its refill threshold.
nonisolated struct StockLevel: Hashable, Sendable {
    /// `nil` when you don't count it.
    let stock: Double?
    let threshold: Double?

    var isTracked: Bool { stock != nil }

    /// At or under the threshold: time to buy more. Without a threshold, only when nothing is left.
    var isLow: Bool {
        guard let stock else { return false }
        return stock <= (threshold ?? 0)
    }

    /// How the stock moves when a dose changes from one mark to another: a taken dose comes off,
    /// undoing it puts it back. Never below zero.
    static func change(from old: DoseMark?, to new: DoseMark?, amount: Double) -> Double {
        (old == .taken ? amount : 0) - (new == .taken ? amount : 0)
    }

    static func applying(_ change: Double, to stock: Double?) -> Double? {
        stock.map { max($0 + change, 0) }
    }
}
