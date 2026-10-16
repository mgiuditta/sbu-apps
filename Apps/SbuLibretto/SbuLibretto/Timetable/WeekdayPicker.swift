import SbuKit
import SwiftUI

/// The days of the week in the calendar's order, Monday first in Italy, as the original's strip.
struct WeekdayPicker: View {
    @Binding var selection: Int
    let slots: [LessonSlot]

    @Environment(\.calendar) private var calendar

    var body: some View {
        Picker("Giorno", selection: $selection) {
            ForEach(LessonSlot.weekdays(calendar: calendar), id: \.self) { weekday in
                Text(verbatim: calendar.veryShortStandaloneWeekdaySymbols[weekday - 1])
                    .accessibilityLabel(Text(verbatim: label(weekday)))
                    .tag(weekday)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("weekday")
    }

    /// "lunedì, 2 lezioni" for VoiceOver: the letter alone says little.
    private func label(_ weekday: Int) -> String {
        let name = calendar.standaloneWeekdaySymbols[weekday - 1]
        let count = LessonSlot.day(weekday, in: slots).count
        return count == 0 ? name : "\(name), " + String(localized: "lezioni: \(count)")
    }
}

#Preview("Light") {
    @Previewable @State var weekday = 2
    List {
        WeekdayPicker(selection: $weekday, slots: [])
    }
}

#Preview("Dark") {
    @Previewable @State var weekday = 4
    List {
        WeekdayPicker(selection: $weekday, slots: [])
    }
    .preferredColorScheme(.dark)
}
