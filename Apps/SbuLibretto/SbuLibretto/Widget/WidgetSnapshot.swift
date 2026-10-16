import Foundation

/// What the widget shows, written by the app into the App Group after every change: the widget
/// never opens the store, so the figures are exactly the app's.
nonisolated struct WidgetSnapshot: Codable, Hashable, Sendable {
    struct NextExam: Codable, Hashable, Sendable {
        let name: String
        let date: Date
    }

    static let key = "widget.snapshot"
    static let widgetKind = "dev.sbu.libretto.average"

    var average: Double?
    var change: Double?
    var earnedCredits: Double
    var totalCredits: Double
    var base: Double?
    /// The coming sittings, soonest first, so the widget can count down for days without the app.
    var nextExams: [NextExam]

    init(average: Double?, change: Double?, earnedCredits: Double, totalCredits: Double, base: Double?, nextExams: [NextExam]) {
        self.average = average
        self.change = change
        self.earnedCredits = earnedCredits
        self.totalCredits = totalCredits
        self.base = base
        self.nextExams = nextExams
    }

    /// The first sitting on or after the day of `now`.
    func nextExam(now: Date, calendar: Calendar) -> NextExam? {
        nextExams.first { !CountdownDay($0.date, from: now, calendar: calendar).isPast }
    }

    static func read(from defaults: UserDefaults) -> WidgetSnapshot? {
        defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(WidgetSnapshot.self, from: $0) }
    }

    func write(to defaults: UserDefaults) {
        if let data = try? JSONEncoder().encode(self) { defaults.set(data, forKey: Self.key) }
    }

    /// For the gallery and the placeholder: made-up, never the user's own.
    static func sample(now: Date) -> WidgetSnapshot {
        WidgetSnapshot(average: 27.77, change: 0.35, earnedCredits: 69, totalCredits: 180, base: 101.83,
                       nextExams: [NextExam(name: String(localized: "Sistemi operativi"), date: now.addingTimeInterval(12 * 86_400))])
    }
}
