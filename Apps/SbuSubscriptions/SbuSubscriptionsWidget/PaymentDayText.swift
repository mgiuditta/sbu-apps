import SwiftUI

/// "oggi", "domani", "tra 3 giorni" or "17 ott", for a payment in a widget's label.
enum PaymentDayText {
    static func text(day: Date, today: Date) -> Text {
        switch DueDay(day, from: today, in: .current) {
        case .today: Text("oggi")
        case .tomorrow: Text("domani")
        case let .inDays(days): Text("tra \(days) giorni")
        case let .on(date): Text(date, format: .dateTime.day().month())
        }
    }
}
