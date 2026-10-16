import Foundation
import Testing
@testable import SbuLibretto

struct WidgetSnapshotTests {
    let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "WidgetSnapshotTests-\(UUID().uuidString)"))
    }

    @Test func theSnapshotRoundTripsThroughTheAppGroup() throws {
        let snapshot = WidgetSnapshot.sample(now: Date(timeIntervalSince1970: 1_790_000_000))
        snapshot.write(to: defaults)
        #expect(WidgetSnapshot.read(from: defaults) == snapshot)
    }

    @Test func aDamagedSnapshotReadsAsNone() {
        #expect(WidgetSnapshot.read(from: defaults) == nil)
        defaults.set(Data([0, 1, 2]), forKey: WidgetSnapshot.key)
        #expect(WidgetSnapshot.read(from: defaults) == nil)
    }

    @Test func theSnapshotCarriesTheLibrettoFigures() throws {
        let now = ExamCountdownTests.now
        let items = [
            PlanItem(id: UUID(), name: "Reti", credits: 6, courseYear: 2, result: .pending, date: ExamCountdownTests.at(day: 20)),
            PlanItem(id: UUID(), name: "Fisica", credits: 6, courseYear: 2, result: .pending, date: ExamCountdownTests.at(day: 1)),
        ]
        let transcript = Transcript([.graded(28, 12, day: 0), .graded(30, 6, day: 1), .passed(3)], rules: .standard)
        let snapshot = WidgetSnapshot(transcript: transcript, countdown: ExamCountdown(items, now: now, calendar: ExamCountdownTests.calendar))
        let average = try #require(snapshot.average)
        #expect(abs(average - 516.0 / 18) < 1e-9)
        #expect(snapshot.earnedCredits == 21)
        #expect(snapshot.totalCredits == 180)
        // Only the coming sittings: the one gone by stays in the app.
        #expect(snapshot.nextExams.map(\.name) == ["Reti"])
    }

    @Test func theWidgetMovesToTheNextSittingOnItsOwn() throws {
        let calendar = ExamCountdownTests.calendar
        let snapshot = WidgetSnapshot(average: 27, change: nil, earnedCredits: 0, totalCredits: 180, base: nil, nextExams: [
            .init(name: "Reti", date: ExamCountdownTests.at(day: 18)),
            .init(name: "Fisica", date: ExamCountdownTests.at(day: 22)),
        ])
        #expect(snapshot.nextExam(now: ExamCountdownTests.at(day: 18, hour: 20), calendar: calendar)?.name == "Reti")
        #expect(snapshot.nextExam(now: ExamCountdownTests.at(day: 19, hour: 0), calendar: calendar)?.name == "Fisica")
        #expect(snapshot.nextExam(now: ExamCountdownTests.at(day: 23), calendar: calendar) == nil)
    }

    @Test(arguments: [1, 7, 0, -5])
    func theTimelineRedrawsAtEachMidnight(_ days: Int) throws {
        let calendar = ExamCountdownTests.calendar
        let now = ExamCountdownTests.now
        let dates = WidgetSnapshot.entryDates(from: now, days: days, calendar: calendar)
        #expect(dates.first == now)
        #expect(dates.count == max(days, 1) + 1)
        for date in dates.dropFirst() {
            #expect(calendar.dateComponents([.hour, .minute], from: date) == DateComponents(hour: 0, minute: 0))
        }
        #expect(dates == dates.sorted())
    }

    @Test func demoLaunchesNeverTouchTheUsersWidget() {
        WidgetSync.publish(.sample(now: .now), mode: .sample, defaults: defaults)
        #expect(WidgetSnapshot.read(from: defaults) == nil)
        WidgetSync.publish(.sample(now: .now), mode: .user, defaults: defaults)
        #expect(WidgetSnapshot.read(from: defaults) != nil)
    }
}
