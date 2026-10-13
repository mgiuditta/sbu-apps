import Foundation

/// When the moon rises and sets on one calendar day at one place.
///
/// The moon comes up about 50 minutes later each day, so about once a month a day has no rise or
/// no set; near the poles it can stay above or below the horizon for days.
nonisolated enum MoonRiseSet: Equatable, Sendable {
    /// The moon crosses the horizon during the day: one or both times, the first of each.
    case crosses(rise: Date?, set: Date?)
    /// Above the horizon the whole day.
    case aboveAllDay
    /// Below the horizon the whole day.
    case belowAllDay
}
