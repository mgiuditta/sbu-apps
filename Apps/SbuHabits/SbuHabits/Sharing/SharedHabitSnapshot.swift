import Foundation

/// What travels of an Abitudine condivisa: the habit as `Habit.sharedCopy` strips it, and the
/// hour the owner's day starts, so other people count its days as the owner does. The owner's
/// iPhone writes it to the habit's zone in the owner's iCloud after every save; other people
/// only ever read it.
nonisolated struct SharedHabitSnapshot: Codable, Equatable, Sendable {
    enum Failure: Error, Equatable {
        /// Written by a newer Sbu Habits: the copy already here stays until this one is updated.
        case newerVersion(Int)
    }

    /// Bump when the format changes in a way this version cannot read back.
    static let currentVersion = 1

    var version = currentVersion
    let habit: Habit
    /// The owner's start of the day, 0 to 6.
    let startHour: Int

    /// The snapshot of `habit` as it should travel: nothing beyond `Habit.sharedCopy`.
    init(habit: Habit, startHour: Int) {
        self.habit = habit.sharedCopy
        self.startHour = Habit.clamp(startHour, to: HabitsFile.startHourRange)
    }

    func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }

    /// Reads a snapshot back, refusing one from a newer app instead of calling it damaged.
    static func decode(_ data: Data) throws -> SharedHabitSnapshot {
        let version = try JSONDecoder().decode(Header.self, from: data).version
        guard version <= currentVersion else { throw Failure.newerVersion(version) }
        let snapshot = try JSONDecoder().decode(SharedHabitSnapshot.self, from: data)
        // Never more than a snapshot may hold, whatever the data says.
        return SharedHabitSnapshot(habit: snapshot.habit, startHour: snapshot.startHour)
    }

    private struct Header: Decodable {
        let version: Int
    }
}
