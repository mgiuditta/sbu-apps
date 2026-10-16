import SbuKit
import SwiftUI

/// A lesson in the day: its times in 24 hours, the course and the room.
struct LessonRow: View {
    let slot: LessonSlot

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space3) {
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: slot.start.text)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                Text(verbatim: slot.end.text)
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            .monospacedDigit()
            VStack(alignment: .leading, spacing: 0) {
                Text(slot.title)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                if !slot.room.isEmpty {
                    Text(slot.room)
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, SbuTheme.space1)
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(slot.title))
        .accessibilityValue(Text(verbatim: [String(localized: "dalle \(slot.start.text) alle \(slot.end.text)"), slot.room].filter { !$0.isEmpty }.joined(separator: ", ")))
    }
}

#Preview("Light") {
    List {
        LessonRow(slot: LessonSlot(id: UUID(), title: "Sistemi operativi", room: "Aula 3.1", weekday: 2,
                                   start: ClockTime(hour: 9, minute: 0), end: ClockTime(hour: 11, minute: 0)))
    }
}

#Preview("Dark") {
    List {
        LessonRow(slot: LessonSlot(id: UUID(), title: "Reti", room: "", weekday: 2,
                                   start: ClockTime(hour: 14, minute: 30), end: ClockTime(hour: 16, minute: 0)))
    }
    .preferredColorScheme(.dark)
}
