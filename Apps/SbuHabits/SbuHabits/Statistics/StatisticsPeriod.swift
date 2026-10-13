import Foundation

/// The span the Statistiche count over, chosen with the button at the top.
nonisolated enum StatisticsPeriod: Int, CaseIterable, Identifiable, Sendable {
    case week
    case month
    case year
    case all

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .week: "Ultimi 7 giorni"
        case .month: "Ultimi 30 giorni"
        case .year: "Ultimo anno"
        case .all: "Dall'inizio"
        }
    }

    /// How many days back it reaches, today included; `nil` from the start.
    var days: Int? {
        switch self {
        case .week: 7
        case .month: 30
        case .year: 365
        case .all: nil
        }
    }

    /// The first day counted: as many days back as the period reaches, never before `start`, the
    /// first day of the oldest habit counted. A start after today, once the clock was moved back,
    /// counts today only.
    func firstDay(today: LogicalDay, start: LogicalDay) -> LogicalDay {
        let start = min(start, today)
        guard let days else { return start }
        return max(start, today - (days - 1))
    }
}
