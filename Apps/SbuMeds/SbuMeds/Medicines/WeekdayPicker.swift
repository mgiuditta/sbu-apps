import SbuKit
import SwiftUI

/// The days of the week, in the calendar's order, each checked or not.
struct WeekdayPicker: View {
    @Binding var selection: Set<Int>

    @Environment(\.calendar) private var calendar

    var body: some View {
        ForEach(weekdays, id: \.self) { weekday in
            Toggle(calendar.weekdaySymbols[weekday - 1].capitalized(with: calendar.locale), isOn: binding(for: weekday))
                .toggleStyle(SbuCheckboxStyle())
        }
    }

    /// 1 is Sunday; Monday first where the week starts on Monday.
    private var weekdays: [Int] {
        (0..<7).map { (calendar.firstWeekday - 1 + $0) % 7 + 1 }
    }

    private func binding(for weekday: Int) -> Binding<Bool> {
        Binding {
            selection.contains(weekday)
        } set: { isOn in
            if isOn { selection.insert(weekday) } else { selection.remove(weekday) }
        }
    }
}

#Preview("Light") {
    WeekdayPickerPreview()
}

#Preview("Dark") {
    WeekdayPickerPreview()
        .preferredColorScheme(.dark)
}

private struct WeekdayPickerPreview: View {
    @State private var selection: Set<Int> = [2, 4, 6]

    var body: some View {
        Form {
            WeekdayPicker(selection: $selection)
        }
        .environment(\.sbuAccent, .meds)
    }
}
