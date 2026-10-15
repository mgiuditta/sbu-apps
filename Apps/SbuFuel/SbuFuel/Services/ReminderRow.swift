import SbuKit
import SwiftUI

/// A reminder in a list: the service, its interval, and how close it is in words.
struct ReminderRow: View {
    let reminder: ServiceReminder
    let due: ReminderDue
    let distanceUnit: DistanceUnit

    var body: some View {
        let words = ReminderWords(reminder: reminder, due: due, distanceUnit: distanceUnit)
        SbuListRow(
            // Interpolated, so your own words are never looked up as a translation key.
            "\(reminder.title)",
            subtitle: words.interval,
            systemImage: reminder.kind.systemImage,
            iconBackground: SbuTheme.surfaceSunken,
            iconForeground: SbuTheme.ink,
            status: words.status,
            statusTone: words.tone
        )
    }
}

#Preview("Light") {
    ReminderRowPreview()
}

#Preview("Dark") {
    ReminderRowPreview()
        .preferredColorScheme(.dark)
}

private struct ReminderRowPreview: View {
    var body: some View {
        let reminder = ServiceReminder(vehicle: nil, kind: .oilChange, title: "Cambio olio", everyKm: 15_000, everyMonths: 12,
                                       lastDoneDate: .now.addingTimeInterval(-86_400 * 300), lastDoneOdometerKm: 40_000)
        List {
            ReminderRow(reminder: reminder, due: ReminderSchedule.due(reminder.rule, estimate: nil, now: .now, calendar: .current), distanceUnit: .kilometres)
        }
    }
}
