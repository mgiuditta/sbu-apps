import Foundation

/// The metadata line under a screen title: `SBU · SOCIAL · MAR 21 OTT`.
nonisolated enum Cartiglio {
    // ponytail: the date is read when the screen draws; a screen left open past midnight keeps yesterday's.
    static var today: String {
        let day = Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
        return String(localized: "Sbu · Social · \(day)")
    }
}
