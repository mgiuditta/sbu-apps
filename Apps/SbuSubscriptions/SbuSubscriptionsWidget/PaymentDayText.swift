import SwiftUI

/// "oggi", "domani", "tra 3 giorni" or "17 ott", for a payment in a widget.
struct PaymentDayText: View {
    let day: Date
    let today: Date

    var body: some View {
        switch DueDay(day, from: today, in: .current) {
        case .today: Text("Oggi")
        case .tomorrow: Text("Domani")
        case let .inDays(days): Text("Tra \(days) giorni")
        case let .on(date): Text(date, format: .dateTime.day().month())
        }
    }
}
