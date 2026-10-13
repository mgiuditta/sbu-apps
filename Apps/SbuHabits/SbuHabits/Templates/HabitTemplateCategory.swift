import Foundation

/// The tabs of the Aggiungi abitudine sheet, in the order it shows them: each has its
/// Modelli and a Personalizzata habit that starts the form the way the tab says.
nonisolated enum HabitTemplateCategory: CaseIterable, Hashable, Sendable {
    case general, health, eating, timed, toAvoid

    var title: LocalizedStringResource {
        switch self {
        case .general: "Generale"
        case .health: "Salute"
        case .eating: "Alimentazione"
        case .timed: "A tempo"
        case .toAvoid: "Da evitare"
        }
    }

    /// The SF Symbol on the tab.
    var symbol: String {
        switch self {
        case .general: "checkmark"
        case .health: "heart.fill"
        case .eating: "fork.knife"
        case .timed: "clock"
        case .toAvoid: "nosign"
        }
    }

    /// What the tab's habits are, under the tabs.
    var explanation: LocalizedStringResource {
        switch self {
        case .general: "Le abitudini da fare: le segni tu, una o più volte al giorno."
        case .health: "Collegate a Salute: si segnano da sole quando arrivi all'obiettivo."
        case .eating: "Quello che mangi e bevi. L'acqua la legge Salute, il resto lo segni tu."
        case .timed: "Parte un conto alla rovescia: l'abitudine è fatta quando arriva a zero."
        case .toAvoid: "Segni ogni volta che cedi. Il giorno è fatto se resti entro il limite."
        }
    }

    /// The header over the tab's Modelli.
    var header: LocalizedStringResource {
        switch self {
        case .general: "Crea un'abitudine"
        case .health: "Crea un'abitudine Salute"
        case .eating: "Crea un'abitudine di alimentazione"
        case .timed: "Crea un'abitudine a tempo"
        case .toAvoid: "Crea un'abitudine da evitare"
        }
    }

    /// The empty form of Personalizzata: a habit to do, linked to Salute, timed or to avoid,
    /// with a symbol of the tab. The link is left out where Salute cannot be read.
    func customDraft(today: LogicalDay, calendar: Calendar = .current, canLinkHealth: Bool = true) -> HabitDraft {
        var draft = HabitDraft(habit: nil, today: today, calendar: calendar)
        switch self {
        case .general:
            break
        case .health:
            draft.symbol = "figure.walk"
            draft.linksHealth = canLinkHealth
        case .eating:
            draft.symbol = "fork.knife"
        case .timed:
            draft.kind = .timed
            draft.symbol = "timer"
        case .toAvoid:
            draft.kind = .toAvoid
            draft.symbol = "nosign"
        }
        return draft
    }
}
