import Foundation

/// How a habit counts, chosen on the form's Tipo screen: done by hand, done when its countdown
/// ends, or kept within a Limite. A habit to do may also link to Salute, which is not a kind.
nonisolated enum HabitKind: CaseIterable, Hashable, Sendable {
    /// Done by hand, or by Salute when linked.
    case toDo
    /// An Abitudine a tempo: its countdown marks it done.
    case timed
    /// An Abitudine da evitare, kept within a Limite.
    case toAvoid

    var title: LocalizedStringResource {
        switch self {
        case .toDo: "Da fare"
        case .timed: "A tempo"
        case .toAvoid: "Da evitare"
        }
    }

    /// The kinds the Tipo screen offers. Da evitare is chosen once, when adding: changing it
    /// would rewrite what the log means. Salute or the countdown marks a habit done, never both,
    /// so a linked habit is not offered A tempo.
    static func choices(isNew: Bool, current: HabitKind, linksHealth: Bool) -> [HabitKind] {
        let kinds: [HabitKind] = if isNew {
            allCases
        } else if current == .toAvoid {
            [.toAvoid]
        } else {
            [.toDo, .timed]
        }
        return kinds.filter { $0 != .timed || linksHealth == false || current == .timed }
    }
}
