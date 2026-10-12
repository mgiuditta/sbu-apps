import SbuKit
import SwiftUI

/// Seven toggles, one per weekday, starting from the first day of the user's week.
struct WeekdayPicker: View {
    @Environment(\.calendar) private var calendar

    @Binding var selection: Set<Int>

    /// Gregorian weekday numbers, 1 for Sunday, in the order the user's week runs.
    private var weekdays: [Int] {
        (0..<7).map { (calendar.firstWeekday - 1 + $0) % 7 + 1 }
    }

    var body: some View {
        HStack(spacing: SbuTheme.space1) {
            ForEach(weekdays, id: \.self) { weekday in
                WeekdayToggle(
                    letter: calendar.veryShortStandaloneWeekdaySymbols[weekday - 1],
                    name: calendar.standaloneWeekdaySymbols[weekday - 1],
                    isOn: selection.contains(weekday)
                ) {
                    toggle(weekday)
                }
            }
        }
        .padding(.vertical, SbuTheme.space2)
    }

    private func toggle(_ weekday: Int) {
        if selection.contains(weekday) {
            selection.remove(weekday)
        } else {
            selection.insert(weekday)
        }
    }
}

private struct WeekdayToggle: View {
    let letter: String
    let name: String
    let isOn: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            Text(letter)
                .font(SbuTheme.subheadline.weight(isOn ? .semibold : .regular))
                .frame(maxWidth: .infinity, minHeight: SymbolPicker.minSize)
                .foregroundStyle(isOn ? SbuTheme.onAccent : SbuTheme.ink)
                .background(isOn ? AnyShapeStyle(.tint) : AnyShapeStyle(SbuTheme.surfaceSunken), in: .circle)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(name)
        .accessibilityAddTraits(isOn ? .isSelected : [])
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
        .tint(SbuTheme.accentHabits)
    }
}
