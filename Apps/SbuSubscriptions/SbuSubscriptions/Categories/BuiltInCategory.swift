import Foundation

/// The categories every store starts with: the 1.0's seventeen, then household bills, then "other".
/// The raw value is the stable key a stored category keeps even after you rename it.
nonisolated enum BuiltInCategory: String, CaseIterable, Codable, Sendable {
    case streaming, music, audio, ai, cloud, vpn, productivity, design, development, gaming, news, fitness, food, social, education, travel, finance
    case water, electricity, gas, internet, rent, mortgage, insurance
    case other

    var symbol: String {
        switch self {
        case .streaming: "tv"
        case .music: "music.note"
        case .audio: "headphones"
        case .ai: "sparkles"
        case .cloud: "icloud"
        case .vpn: "lock.shield"
        case .productivity: "checklist"
        case .design: "paintbrush"
        case .development: "chevron.left.forwardslash.chevron.right"
        case .gaming: "gamecontroller"
        case .news: "newspaper"
        case .fitness: "figure.run"
        case .food: "fork.knife"
        case .social: "person.2"
        case .education: "graduationcap"
        case .travel: "airplane"
        case .finance: "banknote"
        case .water: "drop"
        case .electricity: "bolt"
        case .gas: "flame"
        case .internet: "wifi"
        case .rent: "house"
        case .mortgage: "building.columns"
        case .insurance: "umbrella"
        case .other: "square.grid.2x2"
        }
    }

    var name: String {
        switch self {
        case .streaming: String(localized: "Streaming")
        case .music: String(localized: "Musica")
        case .audio: String(localized: "Audio")
        case .ai: String(localized: "AI")
        case .cloud: String(localized: "Cloud")
        case .vpn: String(localized: "VPN")
        case .productivity: String(localized: "Produttività")
        case .design: String(localized: "Design")
        case .development: String(localized: "Sviluppo")
        case .gaming: String(localized: "Giochi")
        case .news: String(localized: "Notizie")
        case .fitness: String(localized: "Fitness")
        case .food: String(localized: "Cibo")
        case .social: String(localized: "Social")
        case .education: String(localized: "Istruzione")
        case .travel: String(localized: "Viaggi")
        case .finance: String(localized: "Finanza")
        case .water: String(localized: "Acqua")
        case .electricity: String(localized: "Luce")
        case .gas: String(localized: "Gas")
        case .internet: String(localized: "Internet")
        case .rent: String(localized: "Affitto")
        case .mortgage: String(localized: "Mutuo")
        case .insurance: String(localized: "Assicurazione")
        case .other: String(localized: "Altro")
        }
    }

    /// The 1.0 stored its category as this Italian label.
    init?(legacyLabel: String) {
        let labels: [String: BuiltInCategory] = [
            "Streaming": .streaming, "Musica": .music, "Audio": .audio, "AI": .ai, "Cloud": .cloud, "VPN": .vpn,
            "Produttività": .productivity, "Design": .design, "Sviluppo": .development, "Gaming": .gaming, "News": .news,
            "Fitness": .fitness, "Cibo": .food, "Social": .social, "Istruzione": .education, "Viaggi": .travel, "Finanza": .finance,
        ]
        guard let category = labels[legacyLabel] else { return nil }
        self = category
    }
}
