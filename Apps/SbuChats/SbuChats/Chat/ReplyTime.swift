import Foundation

/// How the app writes a reply time: "45 s", "3 min", "1 h 20 min", "2 g 3 h".
enum ReplyTime {
    static func text(_ interval: TimeInterval) -> String {
        let seconds = max(0, interval.rounded())
        let units: Set<Duration.UnitsFormatStyle.Unit> = seconds < 60 ? [.seconds] : [.days, .hours, .minutes]
        return Duration.seconds(seconds).formatted(.units(allowed: units, width: .abbreviated, maximumUnitCount: 2, fractionalPart: .hide))
    }
}
