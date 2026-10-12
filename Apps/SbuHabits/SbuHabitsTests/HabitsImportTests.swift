import Foundation
import Testing
@testable import SbuHabits

struct HabitsImportTests {
    @Test func anExportImportsAsTheSameData() throws {
        let data = try HabitsExport(file: HabitsExportTests.sample, date: .now).data()

        let candidate = try HabitsImport(data: data)

        #expect(candidate.file == HabitsExportTests.sample)
        #expect(candidate.firstDay == LogicalDay(ordinal: 20_000))
    }

    @Test(arguments: [
        #"{"version": 1, "habits": []}"#,
        #"{"version": 0, "habits": [], "startHour": 2}"#,
        #"{"version": 1, "habits": [{"id": "6F9619FF-8B86-D011-B42D-00C04FC964FF", "title": "Leggere", "symbol": "book", "createdOn": 20000, "log": {"20001": 1}}]}"#,
    ])
    func validFilesAreAccepted(json: String) {
        #expect(throws: Never.self) { try HabitsImport(data: Data(json.utf8)) }
    }

    @Test(arguments: [
        ("", HabitsImport.Failure.empty),
        ("not json", .damaged),
        (#"{"habits": []}"#, .damaged),
        (#"{"version": 1}"#, .damaged),
        (#"{"version": 1, "habits": [{"title": "Leggere"}]}"#, .damaged),
        (#"[1, 2, 3]"#, .damaged),
        (#"{"version": 2, "habits": []}"#, .newerVersion),
        (#"{"version": 99, "somethingNew": true}"#, .newerVersion),
    ])
    func invalidFilesSayWhatIsWrong(json: String, failure: HabitsImport.Failure) {
        #expect(throws: failure) { try HabitsImport(data: Data(json.utf8)) }
    }

    /// A habit with one field changed from a valid one, as a hand-edited or crafted file would.
    @Test(arguments: [
        #""createdOn": -1000000000"#, // streaks would walk billions of days on every launch
        #""createdOn": 20000, "skipped": [5]"#,
        #""createdOn": 20000, "timesPerDay": 1000000"#,
        #""createdOn": 20000, "limit": -1"#,
        #""createdOn": 20000, "schedule": {"weekdays": {"_0": [0, 9]}}"#,
        #""createdOn": 20000, "schedule": {"timesPerWeek": {"_0": 40}}"#,
        #""createdOn": 20000, "reminders": [{"hour": 99, "minute": 0}]"#,
        #""createdOn": 9223372036854775807"#, // a day past the end overflows
        #""createdOn": 20000, "health": {"measure": "steps", "goal": 1e300}"#,
        #""createdOn": 20000, "limit": 2, "health": {"measure": "steps", "goal": 8000}"#,
        #""createdOn": 20000, "log": {"20001": 9223372036854775807}"#, // one more mark overflows
        #""createdOn": 20000, "earlier": [{"until": 20000, "timesPerDay": 1, "schedule": {"everyDay": {}}}]"#,
        #""createdOn": 20000, "earlier": [{"until": 20005, "timesPerDay": 1, "schedule": {"everyDay": {}}}, {"until": 20002, "timesPerDay": 1, "schedule": {"everyDay": {}}}]"#,
    ])
    func implausibleHabitsAreRefused(fields: String) {
        // The changed fields first: with a key twice, the decoder keeps the first one.
        let json = #"{"version": 1, "habits": [{"#
            + fields + #", "id": "6F9619FF-8B86-D011-B42D-00C04FC964FF", "title": "Leggere", "symbol": "book", "log": {}}]}"#

        #expect(throws: HabitsImport.Failure.damaged) { try HabitsImport(data: Data(json.utf8)) }
    }

    @Test func aStartOfDayOutOfRangeIsKeptInRange() throws {
        let candidate = try HabitsImport(data: Data(#"{"version": 1, "habits": [], "startHour": 12}"#.utf8))

        #expect(candidate.file.startHour == HabitsFile.startHourRange.upperBound)
    }

    @Test func aFileWithoutHabitsHasNoFirstDay() throws {
        let candidate = try HabitsImport(data: Data(#"{"version": 1, "habits": []}"#.utf8))

        #expect(candidate.firstDay == nil)
    }

    @Test func aMissingFileIsUnreadable() {
        let url = URL.temporaryDirectory.appending(path: "missing-\(UUID().uuidString).json")

        #expect(throws: HabitsImport.Failure.unreadable) { try HabitsImport(contentsOf: url) }
    }

    @Test func replacingRestoresTheFileAndPlansItsReminders() throws {
        let store = HabitsStore(url: .temporaryDirectory.appending(path: "HabitsImportTests-\(UUID().uuidString).json"))
        let plans = PlanLog()
        let model = HabitsModel(store: store, scheduleReminders: plans.record)
        model.add(title: "Camminare", symbol: "figure.walk")

        try model.replace(with: HabitsExportTests.sample)

        #expect(model.file == HabitsExportTests.sample)
        #expect(model.startHour == 4)
        #expect(try store.load() == HabitsExportTests.sample)
        #expect(plans.last?.isEmpty == false)
    }

    @Test func aFailedReplaceChangesNothing() throws {
        let store = HabitsStore(url: .temporaryDirectory.appending(path: "HabitsImportTests-\(UUID().uuidString).json"))
        let model = HabitsModel(store: store, scheduleReminders: { _ in })
        model.add(title: "Camminare", symbol: "figure.walk")
        let before = model.file
        // A newer app wrote the file meanwhile: the store refuses to overwrite it.
        let newer = Data(#"{"version": 99, "habits": []}"#.utf8)
        try newer.write(to: store.url)

        #expect(throws: HabitsStore.Failure.unknownVersion(99)) { try model.replace(with: HabitsExportTests.sample) }
        #expect(model.file == before)
        #expect(try Data(contentsOf: store.url) == newer)
    }

    @Test func aFileOnDiskIsRead() throws {
        let url = URL.temporaryDirectory.appending(path: "import-\(UUID().uuidString).json")
        try HabitsExport(file: HabitsExportTests.sample, date: .now).data().write(to: url)

        #expect(try HabitsImport(contentsOf: url).file == HabitsExportTests.sample)
    }
}
