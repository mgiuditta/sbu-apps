import Foundation

/// Everything Sbu Habits saves: one JSON file in the App Group, shared with the widget.
nonisolated struct HabitsFile: Codable, Equatable, Sendable {
    /// Bump when the format changes in a way this version cannot read back. 2 added the schedules
    /// N volte al mese and Attività di un giorno, which version 1 cannot decode: it refuses the file
    /// as newer instead of calling it damaged, and never overwrites it. The notes came within 2,
    /// before it shipped: an optional field that older files simply lack. So did what Sincronizza
    /// con iCloud needs: the deletions and the dates of the edits.
    static let currentVersion = 2
    /// The hours a day can start at: 0 is midnight, 4 suits a night shift.
    static let startHourRange = 0...6
    /// How long a deletion is remembered: a year. Long enough for an iPhone left in a drawer to
    /// come back without bringing a deleted habit back with it; short enough that the list stays
    /// small. A device away from iCloud for longer could bring one back.
    static let deletionMemory: TimeInterval = 365 * 86_400

    var version = currentVersion
    var habits: [Habit] = []
    /// Hour the logical day starts; what happens before it counts for the day before.
    var startHour = 0
    /// The habits deleted and when, for Sincronizza con iCloud: a deletion wins over any edit,
    /// so a habit deleted on one iPhone never comes back from another.
    var deleted: [UUID: Date] = [:]
    /// When the habits were last reordered, for Sincronizza con iCloud: the newer order wins.
    var orderModifiedAt: Date?
    /// When the start of the day was last changed, for Sincronizza con iCloud: the newer wins.
    var startHourModifiedAt: Date?

    init(habits: [Habit] = [], startHour: Int = 0, deleted: [UUID: Date] = [:], orderModifiedAt: Date? = nil, startHourModifiedAt: Date? = nil) {
        self.habits = habits
        self.startHour = startHour
        self.deleted = deleted
        self.orderModifiedAt = orderModifiedAt
        self.startHourModifiedAt = startHourModifiedAt
    }

    /// Forgets the deletions older than `deletionMemory`.
    mutating func forgetOldDeletions(now: Date) {
        let cutoff = now.addingTimeInterval(-Self.deletionMemory)
        deleted = deleted.filter { $0.value >= cutoff }
    }

    private enum CodingKeys: String, CodingKey {
        case version, habits, startHour, deleted, orderModifiedAt, startHourModifiedAt
    }

    // Files saved before the start of the day existed start at midnight; before sync, nothing
    // was deleted or dated.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        habits = try container.decode([Habit].self, forKey: .habits)
        startHour = try container.decodeIfPresent(Int.self, forKey: .startHour) ?? 0
        // Keyed by the id's text: a dictionary keyed by UUID would encode as a flat array.
        let deleted = try container.decodeIfPresent([String: Date].self, forKey: .deleted) ?? [:]
        self.deleted = Dictionary(deleted.compactMap { key, date in UUID(uuidString: key).map { ($0, date) } }, uniquingKeysWith: max)
        orderModifiedAt = try container.decodeIfPresent(Date.self, forKey: .orderModifiedAt)
        startHourModifiedAt = try container.decodeIfPresent(Date.self, forKey: .startHourModifiedAt)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(habits, forKey: .habits)
        try container.encode(startHour, forKey: .startHour)
        if deleted.isEmpty == false {
            try container.encode(Dictionary(uniqueKeysWithValues: deleted.map { ($0.key.uuidString, $0.value) }), forKey: .deleted)
        }
        try container.encodeIfPresent(orderModifiedAt, forKey: .orderModifiedAt)
        try container.encodeIfPresent(startHourModifiedAt, forKey: .startHourModifiedAt)
    }
}
