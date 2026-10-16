import Foundation

/// What the chore form edits, checked before it reaches the store.
nonisolated struct ChoreDraft: Equatable, Sendable {
    static let maxNameLength = 60
    static let maxNotesLength = 1_000

    var name = ""
    var frequencyValue = 1
    var frequencyUnit = FrequencyUnit.week
    var effort = Effort.medium
    var isOneOff = false
    var notes = ""
    /// New chores only: Tody asks how dirty it is now; here, when you last did it.
    var lastDone: Date

    init(lastDone: Date = .now) {
        self.lastDone = lastDone
    }

    init(preset: ChorePreset, lastDone: Date = .now) {
        name = String(localized: preset.name)
        frequencyValue = preset.frequency.value
        frequencyUnit = preset.frequency.unit
        effort = preset.effort
        self.lastDone = lastDone
    }

    var frequency: Frequency { Frequency(frequencyValue, frequencyUnit) }

    var cleanName: String {
        String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Self.maxNameLength))
    }

    var cleanNotes: String {
        String(notes.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Self.maxNotesLength))
    }

    var isValid: Bool { !cleanName.isEmpty }

    /// Changing the unit keeps the value inside the new unit's range: 30 days become 24 months
    /// at most, never 30 months.
    mutating func select(_ unit: FrequencyUnit) {
        frequencyUnit = unit
        frequencyValue = Frequency(frequencyValue, unit).value
    }

    /// A last-done date in the future counts as now.
    func startDate(now: Date) -> Date { min(lastDone, now) }
}
