import Foundation

/// A Modello: a ready habit of a tab of Aggiungi abitudine, which opens the form filled in
/// with its title, symbol, kind, goal and days. The list is in `HabitTemplate+Catalog.swift`.
nonisolated struct HabitTemplate: Identifiable, Sendable {
    /// Stable within the catalog, for navigation and tests; never saved.
    let id: String
    let title: LocalizedStringResource
    let category: HabitTemplateCategory
    /// An id of `HabitSymbol.all`.
    let symbol: String
    let kind: HabitKind
    let timesPerDay: Int
    let schedule: Schedule
    /// The Limite of an Abitudine da evitare.
    let limit: Int
    /// The countdown of an Abitudine a tempo.
    let timerMinutes: Int
    /// The Salute measure and goal of a linked habit.
    let health: HealthLink?
    /// The Italian and English titles and the keywords, folded for the search.
    let searchTerms: [String]

    private init(_ id: String, _ title: LocalizedStringResource, _ english: String, _ category: HabitTemplateCategory, symbol: String, kind: HabitKind = .toDo, timesPerDay: Int = 1, schedule: Schedule = .everyDay, limit: Int = 0, timerMinutes: Int = 10, health: HealthLink? = nil, keywords: String) {
        self.id = id
        self.title = title
        self.category = category
        self.symbol = symbol
        self.kind = kind
        self.timesPerDay = timesPerDay
        self.schedule = schedule
        self.limit = limit
        self.timerMinutes = timerMinutes
        self.health = health
        searchTerms = SymbolSearch.terms(in: [title.key, english, keywords])
    }

    /// A habit to do, marked by hand.
    /// - Parameters:
    ///   - english: the English title, as in `Localizable.xcstrings`, so the search finds it in either language.
    ///   - keywords: more words, Italian and English, separated by spaces.
    static func toDo(_ id: String, _ title: LocalizedStringResource, _ english: String, _ category: HabitTemplateCategory = .general, symbol: String, timesPerDay: Int = 1, schedule: Schedule = .everyDay, keywords: String = "") -> HabitTemplate {
        HabitTemplate(id, title, english, category, symbol: symbol, timesPerDay: timesPerDay, schedule: schedule, keywords: keywords)
    }

    /// A habit to do linked to a Salute measure, with its goal in the measure's unit.
    static func linked(_ id: String, _ title: LocalizedStringResource, _ english: String, _ category: HabitTemplateCategory = .health, symbol: String, measure: HealthMeasure, goal: Double, keywords: String = "") -> HabitTemplate {
        HabitTemplate(id, title, english, category, symbol: symbol, health: HealthLink(measure: measure, goal: goal), keywords: keywords)
    }

    /// An Abitudine a tempo.
    static func timed(_ id: String, _ title: LocalizedStringResource, _ english: String, symbol: String, minutes: Int, keywords: String = "") -> HabitTemplate {
        HabitTemplate(id, title, english, .timed, symbol: symbol, kind: .timed, timerMinutes: minutes, keywords: keywords)
    }

    /// An Abitudine da evitare.
    static func toAvoid(_ id: String, _ title: LocalizedStringResource, _ english: String, symbol: String, limit: Int, keywords: String = "") -> HabitTemplate {
        HabitTemplate(id, title, english, .toAvoid, symbol: symbol, kind: .toAvoid, limit: limit, keywords: keywords)
    }

    /// The form's draft, with the title in `locale`'s language. The link is left out where
    /// Salute cannot be read: the habit is then marked by hand.
    func draft(today: LogicalDay, calendar: Calendar = .current, locale: Locale = .current, canLinkHealth: Bool = true) -> HabitDraft {
        var draft = HabitDraft(habit: nil, today: today, calendar: calendar)
        draft.kind = kind
        var title = title
        title.locale = locale
        draft.title = String(localized: title)
        draft.symbol = symbol
        draft.timesPerDay = timesPerDay
        draft.limit = limit
        draft.timerMinutes = timerMinutes
        if let health, canLinkHealth {
            draft.linksHealth = true
            draft.healthMeasure = health.measure
            draft.healthGoal = health.goal
        }
        draft.setSchedule(schedule, calendar: calendar)
        return draft
    }

    /// The line under the title in the search results, where Modelli of different tabs meet:
    /// it tells "Leggere" to do from "Leggere" A tempo, and "Meditare" with Salute from the
    /// timed one.
    var detail: LocalizedStringResource {
        health == nil ? kind.title : "Collegata a Salute"
    }

    /// The catalog entry for an id, if it is one.
    static func withID(_ id: String) -> HabitTemplate? {
        index[id]
    }

    /// The Modelli of a tab, in catalog order.
    static func of(_ category: HabitTemplateCategory) -> [HabitTemplate] {
        all.filter { $0.category == category }
    }

    private static let index = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
}
