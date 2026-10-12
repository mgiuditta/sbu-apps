import Foundation

/// What the screen shows for one instant: how lit the moon is, its phase, and the next four principal phases.
nonisolated struct MoonReading: Equatable, Sendable {
    /// The instant this reading is for.
    var date: Date
    /// Fraction of the disc that is lit, 0...1.
    var illumination: Double
    var phase: MoonPhase
    /// The four principal phases strictly after `date`, in order: one of each.
    var upcomingPhases: [PhaseEvent]

    /// Whether the moon is going from new to full: the next full moon comes before the next new one.
    var isWaxing: Bool {
        let full = upcomingPhases.firstIndex { $0.phase == .full } ?? 0
        let new = upcomingPhases.firstIndex { $0.phase == .new } ?? 0
        return full < new
    }

    /// The disc to draw, lit on the side the sun is.
    var disc: MoonDisc { MoonDisc(illumination: illumination, isWaxing: isWaxing) }

    /// Creates the reading for an instant; `calendar` decides which day a principal phase falls on.
    init(date: Date, calendar: Calendar) {
        self.date = date
        illumination = MoonAstronomy.illuminatedFraction(at: date)
        phase = Self.phase(at: date, calendar: calendar)
        // events(around:) spans two lunations after the date, so four always follow it.
        upcomingPhases = Array(MoonAstronomy.events(around: date).filter { $0.date > date }.prefix(PrincipalPhase.allCases.count))
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
