import Foundation

/// When the iPhone reads the figure aloud.
nonisolated enum SpeechMode: String, CaseIterable, Identifiable, Sendable {
    case off
    /// Once the reading settles on a new figure, so you can align something without looking.
    case whenSettled
    /// Every few seconds, whatever it reads.
    case interval

    var id: Self { self }

    var name: LocalizedStringResource {
        switch self {
        case .off: "Mai"
        case .whenSettled: "Quando si ferma"
        case .interval: "Ogni 3 secondi"
        }
    }
}
