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
        #"{"version": 1, "habits": [{"id": "6F9619FF-8B86-D011-B42D-00C04FC964FF", "title": "Acqua", "symbol": "drop", "timesPerDay": 8, "createdOn": 20000, "log": {"20001": 3}, "markHours": {"20001": [9, 14]}}]}"#,
        #"{"version": 1, "habits": [{"id": "6F9619FF-8B86-D011-B42D-00C04FC964FF", "title": "Leggere", "symbol": "book", "createdOn": 20000, "log": {}, "timerMinutes": 180}]}"#,
        #"{"version": 2, "habits": [{"id": "6F9619FF-8B86-D011-B42D-00C04FC964FF", "title": "Biblioteca", "symbol": "book", "schedule": {"timesPerMonth": {"_0": 27}}, "createdOn": 20000, "log": {}}]}"#,
        #"{"version": 2, "habits": [{"id": "6F9619FF-8B86-D011-B42D-00C04FC964FF", "title": "Dentista", "symbol": "pills", "schedule": {"oneDay": {"_0": 20010}}, "createdOn": 20000, "log": {}}]}"#,
        #"{"version": 2, "habits": [{"id": "6F9619FF-8B86-D011-B42D-00C04FC964FF", "title": "Leggere", "symbol": "book", "createdOn": 20000, "log": {}, "notes": {"20001": "Venti pagine\nPoi a letto"}}]}"#,
        #"{"version": 2, "habits": [{"id": "6F9619FF-8B86-D011-B42D-00C04FC964FF", "title": "Leggere", "symbol": "book", "createdOn": 20000, "log": {}, "remindsAutomatically": true, "notificationStyle": {"isTimeSensitive": true, "sound": "punto"}}]}"#,
        // A sound from a later version plays iOS's own instead of refusing the file.
        #"{"version": 2, "habits": [{"id": "6F9619FF-8B86-D011-B42D-00C04FC964FF", "title": "Leggere", "symbol": "book", "createdOn": 20000, "log": {}, "notificationStyle": {"sound": "nuovo"}}]}"#,
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
        (#"{"version": 3, "habits": []}"#, .newerVersion),
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
        #""createdOn": 20000, "schedule": {"timesPerMonth": {"_0": 0}}"#,
        #""createdOn": 20000, "schedule": {"timesPerMonth": {"_0": 28}}"#,
        #""createdOn": 20000, "limit": 2, "schedule": {"timesPerMonth": {"_0": 3}}"#, // an Abitudine da evitare is never monthly
        #""createdOn": 20000, "schedule": {"oneDay": {"_0": 9223372036854775807}}"#, // a day past the end
        #""createdOn": 20000, "limit": 0, "schedule": {"oneDay": {"_0": 20001}}"#,
        #""createdOn": 20000, "reminders": [{"hour": 99, "minute": 0}]"#,
        #""createdOn": 20000, "reminders": [{"hour": 9, "minute": 0}], "remindsAutomatically": true"#, // automatic replaces the times
        #""createdOn": 20000, "limit": 2, "remindsAutomatically": true"#, // an Abitudine da evitare has no reminders
        #""createdOn": 20000, "notificationStyle": {"announcesHealthMark": true}"#, // only Salute marks by itself
        #""createdOn": 9223372036854775807"#, // a day past the end overflows
        #""createdOn": 20000, "health": {"measure": "steps", "goal": 1e300}"#,
        #""createdOn": 20000, "limit": 2, "health": {"measure": "steps", "goal": 8000}"#,
        #""createdOn": 20000, "timerMinutes": 0"#,
        #""createdOn": 20000, "timerMinutes": 181"#,
        #""createdOn": 20000, "limit": 2, "timerMinutes": 10"#, // an Abitudine da evitare is never timed
        #""createdOn": 20000, "health": {"measure": "steps", "goal": 8000}, "timerMinutes": 10"#,
        #""createdOn": 20000, "log": {"20001": 9223372036854775807}"#, // one more mark overflows
        #""createdOn": 20000, "log": {"20001": 1}, "markHours": {"20001": [24]}"#,
        #""createdOn": 20000, "log": {"20001": 1}, "markHours": {"20001": [8, 9]}"#, // more hours than marks
        #""createdOn": 20000, "log": {"20001": 1}, "markHours": {"5": []}"#,
        #""createdOn": 20000, "notes": {"5": "Troppo presto"}"#,
        #""createdOn": 20000, "notes": {"9223372036854775807": "Troppo tardi"}"#,
        #""createdOn": 20000, "notes": {"20001": ""}"#, // a blank note is no note
        #""createdOn": 20000, "notes": {"20001": "  Non tagliata  "}"#,
        #""createdOn": 20000, "notes": {"20001": "\#(String(repeating: "a", count: DailyNote.maxLength + 1))"}"#,
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
