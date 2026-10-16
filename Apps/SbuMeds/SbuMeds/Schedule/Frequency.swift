/// How often a medicine is taken, as in Medisafe's wizard.
nonisolated enum Frequency: String, CaseIterable, Codable, Sendable, Identifiable {
    /// Every day at the chosen times.
    case daily
    /// On the chosen weekdays.
    case weekdays
    /// Every N days from the start day.
    case everyDays
    /// Every N hours from the first time, starting again each day.
    case everyHours
    /// N days on, M days off, from the start day: the pill pack with a pause.
    case cycle
    /// No set time: you mark it when you take it.
    case asNeeded

    var id: String { rawValue }
}
