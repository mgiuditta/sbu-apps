import Testing
@testable import SbuHabits

/// The weekday widget's bars: the tallest day is full height, the others a share of it.
struct WeekdayBarTests {
    /// Monday first, as an Italian week starts.
    private let weekdays = [2, 3, 4, 5, 6, 7, 1]

    @Test(arguments: [
        ([0, 0, 0, 0, 0, 0, 0], [0.0, 0, 0, 0, 0, 0, 0]),
        ([4, 2, 0, 1, 4, 3, 2], [1.0, 0.5, 0, 0.25, 1, 0.75, 0.5]),
        ([0, 0, 0, 0, 0, 0, 9], [0.0, 0, 0, 0, 0, 0, 1]),
    ])
    func eachBarIsAShareOfTheTallest(counts: [Int], fractions: [Double]) {
        let bars = WeekdayBar.bars(from: zip(weekdays, counts).map { WeekdayCount(weekday: $0, count: $1) })

        #expect(bars.map(\.fraction) == fractions)
        #expect(bars.map(\.count) == counts)
        #expect(bars.map(\.weekday) == weekdays)
    }
}
