import Testing
@testable import SbuHabits

struct HabitDayMergeTests {
    nonisolated private static let none = HabitDay()
    nonisolated private static let one = HabitDay(count: 1, hours: [8])
    nonisolated private static let two = HabitDay(count: 2, hours: [8, 9])
    nonisolated private static let three = HabitDay(count: 3, hours: [7, 8, 9])
    nonisolated private static let otherTwo = HabitDay(count: 2, hours: [10, 11])

    /// Both iPhones changed the day, or there was no sync before: the decision's rules.
    @Test(arguments: [
        (local: one, remote: none, expected: one),
        (local: none, remote: one, expected: one),
        (local: two, remote: three, expected: three), // the higher count, not the sum
        (local: three, remote: two, expected: three),
        (local: two, remote: otherTwo, expected: otherTwo), // same count: the same pick on both iPhones
        (local: otherTwo, remote: two, expected: otherTwo),
        (local: HabitDay.skipped, remote: three, expected: HabitDay.skipped), // Salta oggi if either skipped
        (local: two, remote: HabitDay.skipped, expected: HabitDay.skipped),
        (local: HabitDay.skipped, remote: HabitDay.skipped, expected: HabitDay.skipped),
        (local: one, remote: one, expected: one),
    ])
    func withoutAnEarlierSyncTheRulesDecide(local: HabitDay, remote: HabitDay, expected: HabitDay) {
        #expect(HabitDay.merge(local, remote, base: nil) == expected)
    }

    /// One iPhone changed the day since the last sync: its change wins, taking back included.
    @Test(arguments: [
        (local: two, remote: three, base: three, expected: two), // a mark taken back here
        (local: three, remote: one, base: three, expected: one), // two taken back on the other iPhone
        (local: none, remote: two, base: two, expected: none), // every mark taken back
        (local: two, remote: HabitDay.skipped, base: HabitDay.skipped, expected: two), // a skip taken back, then marked
        (local: none, remote: HabitDay.skipped, base: HabitDay.skipped, expected: none),
        (local: three, remote: one, base: one, expected: three),
        (local: one, remote: one, base: none, expected: one), // both made the same change
    ])
    func aSideUnchangedSinceTheLastSyncTakesTheOthersChange(local: HabitDay, remote: HabitDay, base: HabitDay, expected: HabitDay) {
        #expect(HabitDay.merge(local, remote, base: base) == expected)
    }

    /// Both iPhones changed the day since the last sync: the rules decide again.
    @Test(arguments: [
        (local: one, remote: three, base: two, expected: three),
        (local: HabitDay.skipped, remote: three, base: one, expected: HabitDay.skipped),
        (local: none, remote: three, base: one, expected: three),
    ])
    func bothChangedTheRulesDecide(local: HabitDay, remote: HabitDay, base: HabitDay, expected: HabitDay) {
        #expect(HabitDay.merge(local, remote, base: base) == expected)
    }

    @Test(arguments: [none, one, two, three, otherTwo, HabitDay.skipped], [none, one, two, three, otherTwo, HabitDay.skipped])
    func theOrderOfTheSidesNeverMatters(local: HabitDay, remote: HabitDay) {
        #expect(HabitDay.merge(local, remote, base: nil) == HabitDay.merge(remote, local, base: nil))
        for base in [Self.none, Self.one, Self.two, HabitDay.skipped] {
            #expect(HabitDay.merge(local, remote, base: base) == HabitDay.merge(remote, local, base: base))
        }
    }
}
