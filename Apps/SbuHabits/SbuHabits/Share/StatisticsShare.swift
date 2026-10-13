import Foundation

/// What a shared Statistiche image shows: the page on show, every habit or one, over the period
/// chosen, with the numbers that page already has. Its words are worked out here, so the title,
/// the file name and the description of the image say the same thing.
nonisolated struct StatisticsShare: Equatable, Sendable {
    /// The habit's title, `nil` for the page of every habit.
    let habitTitle: String?
    /// The habit's SF Symbol, `nil` for the page of every habit.
    let symbol: String?
    /// The unit of the Serie migliore: days, or weeks or months for a counted habit.
    let streakSchedule: Schedule
    let period: StatisticsPeriod
    let statistics: HabitStatistics

    /// The page `page` of the Statistiche: 0 for every habit, then one per habit in `habits`'
    /// order, as the pager counts them. A page past the habits, once one was deleted, falls back
    /// to every habit.
    init(page: Int, habits: [Habit], period: StatisticsPeriod, statistics: HabitStatistics) {
        let habit = Self.habit(on: page, in: habits)
        habitTitle = habit?.title
        symbol = habit?.symbol
        streakSchedule = habit?.schedule ?? .everyDay
        self.period = period
        self.statistics = statistics
    }

    /// The habit of page `page`, `nil` for the page of every habit or a page past the habits.
    static func habit(on page: Int, in habits: [Habit]) -> Habit? {
        habits.indices.contains(page - 1) ? habits[page - 1] : nil
    }

    /// The habit's title, or Tutte le abitudini.
    func subject(locale: Locale = .current) -> String {
        habitTitle ?? Self.resolve("Tutte le abitudini", locale)
    }

    /// The period's name, as the button at the top shows it.
    func periodName(locale: Locale = .current) -> String {
        Self.resolve(period.title, locale)
    }

    /// The share sheet's title: "Sbu Habits · Leggere · Ultimi 30 giorni".
    func title(locale: Locale = .current) -> String {
        ["Sbu Habits", subject(locale: locale), periodName(locale: locale)].joined(separator: " · ")
    }

    /// The image's file name, without extension: the title with characters no file system takes
    /// replaced, "Sbu Habits - Leggere - Ultimi 30 giorni".
    func fileName(locale: Locale = .current) -> String {
        let name = ["Sbu Habits", subject(locale: locale), periodName(locale: locale)].joined(separator: " - ")
        let unsafe = CharacterSet(charactersIn: "/\\:?%*|\"<>").union(.newlines).union(.controlCharacters)
        return name.unicodeScalars
            .map { unsafe.contains($0) ? "-" : String($0) }
            .joined()
            .trimmingCharacters(in: .whitespaces)
    }

    /// The completion rate as the figure shows it, an en dash when nothing was expected.
    func rate(locale: Locale = .current) -> String {
        statistics.tally.rate?.formatted(.percent.precision(.fractionLength(0...1)).locale(locale)) ?? "–"
    }

    /// What the image shows, for whoever cannot see it: written into the image's description.
    func imageDescription(locale: Locale = .current) -> String {
        let streak = Self.resolve(streakSchedule.streakText(statistics.bestStreak), locale)
        let completions = statistics.completions.formatted(.number.locale(locale))
        let resource: LocalizedStringResource = "\(subject(locale: locale)), \(periodName(locale: locale)): completamento \(rate(locale: locale)), serie migliore \(streak), completamenti \(completions)."
        return Self.resolve(resource, locale)
    }

    private static func resolve(_ resource: LocalizedStringResource, _ locale: Locale) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }
}
