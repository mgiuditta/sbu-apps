import Foundation

/// How long the alarm takes to reach full volume.
nonisolated enum AlarmFadeIn: Int, Codable, CaseIterable, Identifiable, Sendable {
    case none = 0
    case thirtySeconds = 30
    case oneMinute = 60
    case twoMinutes = 120
    case fiveMinutes = 300
    case tenMinutes = 600

    var id: Self { self }
    var duration: Duration { .seconds(rawValue) }

    /// "Nessuna", "30 secondi", "1 minuto".
    var label: String {
        self == .none
            ? String(localized: "Nessuna")
            : duration.formatted(.units(allowed: [.minutes, .seconds], width: .wide))
    }
}
