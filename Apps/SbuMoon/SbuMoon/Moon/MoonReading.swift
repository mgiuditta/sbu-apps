import Foundation

/// What the screen shows for one instant: how lit the moon is, its phase, and the next full and new moon.
nonisolated struct MoonReading: Equatable, Sendable {
    /// The instant this reading is for.
    var date: Date
    /// Fraction of the disc that is lit, 0...1.
    var illumination: Double
    var phase: MoonPhase
    /// The first full moon strictly after `date`.
    var nextFullMoon: Date
    /// The first new moon strictly after `date`.
    var nextNewMoon: Date

    /// Creates the reading for an instant; `calendar` decides which day a principal phase falls on.
    init(date: Date, calendar: Calendar) {
        self.date = date
        illumination = MoonAstronomy.illuminatedFraction(at: date)
        phase = Self.phase(at: date, calendar: calendar)
        nextFullMoon = MoonAstronomy.next(.full, after: date)
        nextNewMoon = MoonAstronomy.next(.new, after: date)
    }

    /// A principal phase names its whole calendar day; between two of them the moon is
    /// crescent or gibbous, waxing or waning, after the last one that passed.
    static func phase(at date: Date, calendar: Calendar) -> MoonPhase {
        let events = MoonAstronomy.events(around: date)
        if let today = events.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            return today.phase.phase
        }
        // events(around:) spans two lunations either side, so one has always passed.
        let previous = events.last { $0.date <= date }
        return previous?.phase.following ?? .waxingCrescent
    }
}
