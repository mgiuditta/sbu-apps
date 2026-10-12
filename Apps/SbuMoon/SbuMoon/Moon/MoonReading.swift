import Foundation

/// What the screen shows for one instant: how lit the moon is, its phase, the next four principal
/// phases, the moon's age and its distance.
nonisolated struct MoonReading: Equatable, Sendable {
    /// The instant this reading is for.
    var date: Date
    /// Fraction of the disc that is lit, 0...1.
    var illumination: Double
    var phase: MoonPhase
    /// The four principal phases strictly after `date`, in order: one of each.
    var upcomingPhases: [PhaseEvent]
    /// Age of the moon: time since the last new moon at or before `date`.
    var age: Duration
    /// Distance between the centres of the Earth and the moon.
    var distance: Measurement<UnitLength>

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
        // events(around:) spans two lunations either side, so a new moon has always passed and four phases follow.
        let events = MoonAstronomy.events(around: date)
        upcomingPhases = Array(events.filter { $0.date > date }.prefix(PrincipalPhase.allCases.count))
        let lastNewMoon = events.last { $0.phase == .new && $0.date <= date }?.date ?? date
        age = .seconds(date.timeIntervalSince(lastNewMoon))
        distance = Measurement(value: MoonDistance.kilometres(at: date), unit: .kilometers)
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
