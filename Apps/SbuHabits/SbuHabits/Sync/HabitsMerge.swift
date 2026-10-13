import Foundation

/// Joins this iPhone's habits with the copy on iCloud, for Sincronizza con iCloud. Pure: the same
/// two copies give the same result on every iPhone, in either order, so they agree after a sync.
///
/// - Marks of the same day: the higher count wins, with its hours, never the sum. Salta oggi
///   wins if either side skipped. A side unchanged since the last sync takes the other's change,
///   so taking back a mark or a skip travels too (`HabitDay`).
/// - Notes: the newer edit of each day wins, clearing included.
/// - Settings (title, symbol, goal, schedule and its history, Limite, reminders, notifications,
///   Salute, timer): the newer edit wins, all together.
/// - A deleted habit stays deleted, even over a later edit on the other side.
/// - The order and the start of the day: the newer change wins. Habits only one side knows go
///   after the others.
/// - Two habits created apart are two habits, even with the same title.
nonisolated enum HabitsMerge {
    /// - Parameters:
    ///   - base: Both sides as they were after the last sync, `nil` before the first one.
    ///   - now: Deletions older than `HabitsFile.deletionMemory` from now are forgotten.
    static func merge(_ local: HabitsFile, _ remote: HabitsFile, base: HabitsFile?, now: Date) -> HabitsFile {
        let deleted = local.deleted.merging(remote.deleted, uniquingKeysWith: max)
        let localHabits = Dictionary(local.habits.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let remoteHabits = Dictionary(remote.habits.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let baseHabits = Dictionary((base?.habits ?? []).map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        let (first, second) = newerFirst(
            (local, local.orderModifiedAt, local.habits.map(\.id.uuidString)),
            (remote, remote.orderModifiedAt, remote.habits.map(\.id.uuidString))
        )
        var order = first.habits.map(\.id)
        order += second.habits.map(\.id).filter { localHabits[$0] == nil || remoteHabits[$0] == nil }
        let habits = order.compactMap { id -> Habit? in
            // Checked before old deletions are forgotten: a deletion always wins.
            guard deleted[id] == nil else { return nil }
            switch (localHabits[id], remoteHabits[id]) {
            case let (local?, remote?): return merge(local, remote, base: baseHabits[id])
            case let (local?, nil): return local
            case let (nil, remote?): return remote
            case (nil, nil): return nil
            }
        }

        let (startFirst, _) = newerFirst(
            (local, local.startHourModifiedAt, [String(local.startHour)]),
            (remote, remote.startHourModifiedAt, [String(remote.startHour)])
        )
        var merged = HabitsFile(
            habits: habits,
            startHour: startFirst.startHour,
            deleted: deleted,
            orderModifiedAt: [local.orderModifiedAt, remote.orderModifiedAt].compactMap { $0 }.max(),
            startHourModifiedAt: [local.startHourModifiedAt, remote.startHourModifiedAt].compactMap { $0 }.max()
        )
        merged.forgetOldDeletions(now: now)
        return merged
    }

    /// One habit both sides know: the newer settings, then each day and each note.
    static func merge(_ local: Habit, _ remote: Habit, base: Habit?) -> Habit {
        var merged = newerSettings(local, remote)
        let days = Set([local, remote].flatMap { Array($0.log.keys) + Array($0.markHours.keys) + Array($0.skipped) })
        for day in days {
            let result = HabitDay.merge(HabitDay(local, on: day), HabitDay(remote, on: day), base: base.map { HabitDay($0, on: day) })
            merged.setDay(count: result.count, hours: result.hours, isSkipped: result.isSkipped, on: day)
        }
        let noteDays = Set([local, remote].flatMap { Array($0.notes.keys) + Array($0.noteDates.keys) })
        for day in noteDays {
            let localNote = (date: local.noteDates[day] ?? .distantPast, text: local.notes[day] ?? "")
            let remoteNote = (date: remote.noteDates[day] ?? .distantPast, text: remote.notes[day] ?? "")
            let winner = isNewer(localNote.date, localNote.text, than: remoteNote.date, remoteNote.text) ? local : remote
            merged.restoreNote(winner.notes[day], editedAt: winner.noteDates[day], on: day)
        }
        return merged
    }

    /// The side whose settings were edited last. Equal dates with different settings, which a
    /// clock never makes but old files can, pick by content so both iPhones choose the same.
    private static func newerSettings(_ local: Habit, _ remote: Habit) -> Habit {
        let localDate = local.modifiedAt ?? .distantPast
        let remoteDate = remote.modifiedAt ?? .distantPast
        if localDate != remoteDate {
            return localDate > remoteDate ? local : remote
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let localData = (try? encoder.encode(local.settingsOnly)) ?? Data()
        let remoteData = (try? encoder.encode(remote.settingsOnly)) ?? Data()
        return localData.lexicographicallyPrecedes(remoteData) ? remote : local
    }

    /// The pair whose change is newer first; equal dates fall back to `key`, the same way on
    /// every iPhone.
    private static func newerFirst(_ local: (HabitsFile, Date?, [String]), _ remote: (HabitsFile, Date?, [String])) -> (HabitsFile, HabitsFile) {
        let localDate = local.1 ?? .distantPast
        let remoteDate = remote.1 ?? .distantPast
        let localWins = localDate != remoteDate ? localDate > remoteDate : remote.2.lexicographicallyPrecedes(local.2) || remote.2 == local.2
        return localWins ? (local.0, remote.0) : (remote.0, local.0)
    }

    private static func isNewer(_ date: Date, _ text: String, than otherDate: Date, _ otherText: String) -> Bool {
        date != otherDate ? date > otherDate : otherText <= text
    }
}
