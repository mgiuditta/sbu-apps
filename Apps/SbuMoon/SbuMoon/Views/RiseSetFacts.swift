import SwiftUI

/// The rows of the rise and set card: two, or one when the moon stays on one side of the horizon all day.
enum RiseSetFacts {
    static func facts(for riseSet: MoonRiseSet) -> [MoonFact] {
        switch riseSet {
        case let .crosses(rise, set):
            [MoonFact(id: "rise", label: "Sorge", value: time(rise)), MoonFact(id: "set", label: "Tramonta", value: time(set))]
        case .aboveAllDay:
            [MoonFact(id: "above", label: "Sorgere e tramonto", value: Text("Sopra l'orizzonte tutto il giorno"))]
        case .belowAllDay:
            [MoonFact(id: "below", label: "Sorgere e tramonto", value: Text("Sotto l'orizzonte tutto il giorno"))]
        }
    }

    /// The time, or that there is none on the day shown, which need not be today.
    private static func time(_ date: Date?) -> Text {
        if let date {
            Text(date, format: .dateTime.hour().minute())
        } else {
            Text("Non in questo giorno")
        }
    }
}
