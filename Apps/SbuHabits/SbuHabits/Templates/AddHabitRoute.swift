import Foundation

/// What a row of Aggiungi abitudine opens: the form of a Personalizzata habit or of a Modello.
nonisolated enum AddHabitRoute: Hashable, Sendable {
    case custom(HabitTemplateCategory)
    /// A `HabitTemplate.id`.
    case template(String)

    /// The form's draft for the route; a blank one for an id that is not in the catalog.
    func draft(today: LogicalDay, calendar: Calendar = .current, locale: Locale = .current, canLinkHealth: Bool = true) -> HabitDraft {
        switch self {
        case .custom(let category):
            category.customDraft(today: today, calendar: calendar, canLinkHealth: canLinkHealth)
        case .template(let id):
            HabitTemplate.withID(id)?.draft(today: today, calendar: calendar, locale: locale, canLinkHealth: canLinkHealth)
                ?? HabitDraft(habit: nil, today: today, calendar: calendar)
        }
    }
}
