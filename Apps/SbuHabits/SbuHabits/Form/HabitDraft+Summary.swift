import Foundation

/// The values the form's rows show on the right, in the language and format of `locale`.
nonisolated extension HabitDraft {
    /// The Tipo row: "Da fare", "A tempo", "Da evitare".
    func kindSummary(locale: Locale = .current) -> String {
        Self.resolve(kind.title, locale)
    }

    /// The goal row: "3 volte al giorno", "Mai", "2 al giorno", "10 min", "8000 passi";
    /// `nil` when the kind has no goal to set.
    func goalSummary(locale: Locale = .current) -> String? {
        switch goal {
        case .timesPerDay:
            Self.resolve("\(timesPerDay) volte al giorno", locale)
        case .limit:
            limit == 0 ? Self.resolve("Mai", locale) : Self.resolve("\(limit) al giorno", locale)
        case .duration:
            Duration.seconds(timerMinutes * 60).formatted(TimerFormat.length.locale(locale))
        case .health:
            healthMeasure.formatted(healthGoal, locale: locale)
        case nil:
            nil
        }
    }

    /// The Giorni row: "Ogni giorno", "lun, mer e ven", "3 volte a settimana", "14 ott".
    func daysSummary(calendar: Calendar = .current, locale: Locale = .current) -> String {
        switch scheduleKind {
        case .everyDay:
            return Self.resolve("Ogni giorno", locale)
        case .weekdays:
            if weekdays.isEmpty { return Self.resolve("Nessun giorno", locale) }
            if weekdays.count == 7 { return Self.resolve("Tutti i giorni", locale) }
            var named = calendar
            named.locale = locale
            let names = (0..<7)
                .map { (calendar.firstWeekday - 1 + $0) % 7 + 1 }
                .filter(weekdays.contains)
                .map { named.shortStandaloneWeekdaySymbols[$0 - 1] }
            return names.formatted(.list(type: .and).locale(locale))
        case .timesPerWeek:
            return Self.resolve("\(timesPerWeek) volte a settimana", locale)
        case .timesPerMonth:
            return Self.resolve("\(timesPerMonth) volte al mese", locale)
        case .oneDay:
            var format = Date.FormatStyle.dateTime.day().month(.abbreviated).locale(locale)
            format.calendar = calendar
            format.timeZone = calendar.timeZone
            return oneDay.formatted(format)
        }
    }

    /// The Salute row: the measure, or "Non collegata".
    func healthSummary(locale: Locale = .current) -> String {
        linksHealth ? Self.resolve(healthMeasure.title, locale) : Self.resolve("Non collegata", locale)
    }

    /// The Notifiche row: "Nessuna", "Automatici", the one time ("09:00"), or "3 promemoria".
    /// - Parameter times: The Orari personalizzati, read only in that mode.
    func remindersSummary(times: [Date], calendar: Calendar = .current, locale: Locale = .current) -> String {
        switch reminderMode {
        case .off: Self.resolve("Nessuna", locale)
        case .automatic: Self.resolve("Automatici", locale)
        case .custom: Self.remindersSummary(times, calendar: calendar, locale: locale)
        }
    }

    /// Orari personalizzati: "Nessuna", the one time ("09:00"), or "3 promemoria".
    static func remindersSummary(_ times: [Date], calendar: Calendar = .current, locale: Locale = .current) -> String {
        switch times.count {
        case 0:
            return resolve("Nessuna", locale)
        case 1:
            var format = Date.FormatStyle.dateTime.hour().minute().locale(locale)
            format.calendar = calendar
            format.timeZone = calendar.timeZone
            return times[0].formatted(format)
        default:
            return resolve("\(times.count) promemoria", locale)
        }
    }

    private static func resolve(_ resource: LocalizedStringResource, _ locale: Locale) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }
}
