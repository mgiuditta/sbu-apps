/// The longest run of consecutive days in a set of day numbers.
nonisolated enum Streak {
    static func longest(in days: Set<Int>) -> Int {
        var best = 0
        for day in days where !days.contains(day - 1) {
            var length = 1
            while days.contains(day + length) { length += 1 }
            best = max(best, length)
        }
        return best
    }
}
