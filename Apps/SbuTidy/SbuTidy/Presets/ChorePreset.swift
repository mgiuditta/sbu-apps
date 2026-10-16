import Foundation

/// A ready-made chore in the new-chore picker: a name in your language, a frequency and an effort.
nonisolated struct ChorePreset: Hashable, Sendable {
    let name: LocalizedStringResource
    let frequency: Frequency
    let effort: Effort

    init(_ name: LocalizedStringResource, every value: Int, _ unit: FrequencyUnit, effort: Effort) {
        self.name = name
        frequency = Frequency(value, unit)
        self.effort = effort
    }

    static func == (lhs: ChorePreset, rhs: ChorePreset) -> Bool {
        lhs.name.key == rhs.name.key && lhs.frequency == rhs.frequency && lhs.effort == rhs.effort
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name.key)
        hasher.combine(frequency)
        hasher.combine(effort)
    }
}
