import Foundation

/// The groups of the catalog, as in the original's menu.
nonisolated enum SoundCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case noise
    case rain
    case water
    case nature
    case home
    case travel

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .noise: "Rumori"
        case .rain: "Pioggia"
        case .water: "Acqua"
        case .nature: "Natura"
        case .home: "Casa"
        case .travel: "Viaggio"
        }
    }

    var systemImage: String {
        switch self {
        case .noise: "waveform"
        case .rain: "cloud.rain"
        case .water: "water.waves"
        case .nature: "leaf"
        case .home: "house"
        case .travel: "tram"
        }
    }
}
