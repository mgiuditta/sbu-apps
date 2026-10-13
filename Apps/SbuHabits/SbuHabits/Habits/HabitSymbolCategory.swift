import Foundation

/// The groups of the symbol picker, in the order it shows them.
nonisolated enum HabitSymbolCategory: CaseIterable, Sendable {
    case health, sport, food, home, work, mind, nature, people, money, time, travel, technology, creativity, other

    var title: LocalizedStringResource {
        switch self {
        case .health: "Salute e corpo"
        case .sport: "Sport"
        case .food: "Cibo e bevande"
        case .home: "Casa e cura"
        case .work: "Lavoro e studio"
        case .mind: "Mente e umore"
        case .nature: "Natura e animali"
        case .people: "Persone"
        case .money: "Soldi e acquisti"
        case .time: "Tempo"
        case .travel: "Viaggi"
        case .technology: "Tecnologia"
        case .creativity: "Creatività"
        case .other: "Altro"
        }
    }
}
