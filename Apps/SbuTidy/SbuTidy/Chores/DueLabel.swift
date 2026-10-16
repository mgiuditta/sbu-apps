import Foundation

/// The words under a chore, as Tody's: "Tra 7 giorni", "Oggi", "6 giorni di ritardo".
nonisolated enum DueLabel: Hashable, Sendable {
    case today
    case tomorrow
    case inDays(Int)
    case late(days: Int)
    case paused

    init(_ state: ChoreState) {
        self = switch state.status {
        case .paused: .paused
        case .due: .today
        case .overdue: .late(days: -state.daysUntilDue)
        case .clean: state.daysUntilDue == 1 ? .tomorrow : .inDays(state.daysUntilDue)
        }
    }

    var text: LocalizedStringResource {
        switch self {
        case .today: "Oggi"
        case .tomorrow: "Domani"
        case let .inDays(days): "Tra \(days) giorni"
        case let .late(days): "\(days) giorni di ritardo"
        case .paused: "In pausa"
        }
    }
}
