import Foundation

nonisolated extension SoundTimerFade {
    /// "Nessuna", "10 secondi", "1 minuto".
    var label: String {
        self == .none
            ? String(localized: "Nessuna")
            : Duration.seconds(rawValue).formatted(.units(allowed: [.minutes, .seconds], width: .wide))
    }
}
