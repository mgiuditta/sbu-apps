import Foundation
import Testing
@testable import SbuHabits

struct WatchPayloadTests {
    private let today = LogicalDay(ordinal: 1_004)

    @Test func aGridCrossesIntact() throws {
        var water = Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 8, createdOn: today - 3)
        water.mark(on: today, hour: 7)
        let snapshot = WatchSnapshot(habits: [water], today: today, startHour: 4, firstWeekday: 2, nextDayStart: Date(timeIntervalSince1970: 86_400_000), applied: [UUID()])

        #expect(WatchPayload.snapshot(from: try WatchPayload.context(for: snapshot)) == snapshot)
    }

    @Test(arguments: [WatchAction.Kind.mark, .undo])
    func aTapCrossesIntact(kind: WatchAction.Kind) throws {
        let action = WatchAction(habitID: UUID(), day: today, hour: 23, kind: kind)

        #expect(WatchPayload.action(from: try WatchPayload.userInfo(for: action)) == action)
    }

    @Test func somethingElseIsNeitherAGridNorATap() {
        let garbage: [String: Any] = ["snapshot": Data("{}".utf8), "action": "segna"]

        #expect(WatchPayload.snapshot(from: garbage) == nil)
        #expect(WatchPayload.action(from: garbage) == nil)
        #expect(WatchPayload.isRefreshRequest(garbage) == false)
        #expect(WatchPayload.isRefreshRequest(WatchPayload.refreshRequest))
    }
}
