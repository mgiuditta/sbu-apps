import Testing
@testable import SbuHabits

struct ActivityRingsTests {
    @Test(arguments: [
        (ActivityRings(move: 0, moveGoal: 500, exercise: 0, exerciseGoal: 30, stand: 0, standGoal: 12), 0),
        (ActivityRings(move: 500, moveGoal: 500, exercise: 10, exerciseGoal: 30, stand: 4, standGoal: 12), 1),
        (ActivityRings(move: 620, moveGoal: 500, exercise: 30, exerciseGoal: 30, stand: 4, standGoal: 12), 2),
        (ActivityRings(move: 620, moveGoal: 500, exercise: 45, exerciseGoal: 30, stand: 12, standGoal: 12), 3),
    ])
    func aRingClosesAtItsGoal(rings: ActivityRings, closed: Int) {
        #expect(rings.closed == closed)
    }

    @Test func aRingWithNoGoalNeverCloses() {
        let rings = ActivityRings(move: 300, moveGoal: 0, exercise: 30, exerciseGoal: 0, stand: 12, standGoal: 0)

        #expect(rings.closed == 0)
    }

    @Test(arguments: 1...3)
    func theClosedRingsMarkAHabitFromItsGoal(goal: Int) {
        let link = HealthLink(measure: .activityRings, goal: Double(goal))
        let rings = ActivityRings(move: 500, moveGoal: 500, exercise: 30, exerciseGoal: 30, stand: 0, standGoal: 12)

        #expect(link.isReached(by: Double(rings.closed)) == (goal <= 2))
    }
}
