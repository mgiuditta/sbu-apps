import SwiftUI

/// The days a clock timer repeats on, in the locale's week order; none means once.
struct WeekdaysPicker: View {
    @Binding var selection: Set<Int>

    private let calendar = Calendar.current

    var body: some View {
        List(SoundTimer.orderedWeekdays(calendar), id: \.self) { weekday in
            let isSelected = selection.contains(weekday)
            Button {
                if isSelected { selection.remove(weekday) } else { selection.insert(weekday) }
            } label: {
                HStack {
                    Text(calendar.weekdaySymbols[weekday - 1].localizedCapitalized)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark")
                            .fontWeight(.medium)
                            .foregroundStyle(.tint)
                    }
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
        .navigationTitle("Ripeti")
    }
}

#Preview("Light") {
    NavigationStack { WeekdaysPicker(selection: .constant([2, 4])) }
}

#Preview("Dark") {
    NavigationStack { WeekdaysPicker(selection: .constant([1, 7])) }
        .preferredColorScheme(.dark)
}
