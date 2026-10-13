import Foundation

/// Moonrise and moonset at a place on the day shown, told by the place's own clock: a chosen city
/// keeps its time zone, the iPhone's position uses the iPhone's.
nonisolated struct PlaceRiseSet: Equatable, Sendable {
    var riseSet: MoonRiseSet
    /// The clock the times are read in.
    var timeZone: TimeZone
    /// Whether that clock shows a different time from the iPhone's on the day shown, so the
    /// screen has to say which one it is.
    var isOtherTimeZone: Bool

    /// - Parameters:
    ///   - shownDate: The instant on screen; its calendar day on the iPhone is the day worked out.
    ///   - coordinates: Where the moon is watched from.
    ///   - timeZone: The place's clock, or `nil` to use the iPhone's.
    ///   - deviceCalendar: The iPhone's calendar and time zone.
    init(shownDate: Date, coordinates: Coordinates, timeZone: TimeZone?, deviceCalendar: Calendar) {
        let zone = timeZone ?? deviceCalendar.timeZone
        var placeCalendar = deviceCalendar
        placeCalendar.timeZone = zone

        // The same date as the pill says, at noon on the place's clock.
        var day = deviceCalendar.dateComponents([.era, .year, .month, .day], from: shownDate)
        day.hour = 12
        let noon = placeCalendar.date(from: day) ?? shownDate

        riseSet = MoonHorizon.riseSet(on: noon, at: coordinates, calendar: placeCalendar)
        self.timeZone = zone
        isOtherTimeZone = zone.secondsFromGMT(for: noon) != deviceCalendar.timeZone.secondsFromGMT(for: noon)
    }
}
