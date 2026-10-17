import SbuKit
import SwiftUI

/// An Abitudine condivisa received, on the tool screen: read only, so a row mark instead of the
/// checkbox, filled once the owner's day is done, the Serie in IBM Plex Mono and the owner's
/// badge. A tap opens its screen with the statistics.
struct SharedHabitRow: View {
    let display: SharedHabitDisplay
    let open: () -> Void

    private var accessibilityValue: Text {
        display.face.progressText + Text(verbatim: ", ") + Text(display.habit.schedule.streakText(display.streak))
            + Text(verbatim: ", ") + Text("condivisa da un'altra persona")
    }

    var body: some View {
        Button(action: open) {
            HStack(spacing: SbuTheme.space3) {
                SbuRowMark(filled: display.progress.isComplete)
                    .frame(width: SbuTheme.checkbox)
                Text(display.habit.title)
                    .fontWeight(.medium)
                    .foregroundStyle(SbuTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(display.habit.schedule.shortStreakText(display.streak))
                    .font(.sbuCartiglio)
                    .monospacedDigit()
                    .foregroundStyle(SbuTheme.inkMuted)
                    .fixedSize()
                OwnerBadge(emoji: display.ownerEmoji)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(display.habit.title)
        .accessibilityValue(accessibilityValue)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(.default, open)
    }
}

#Preview("Light") {
    SharedHabitRowPreview()
}

#Preview("Dark") {
    SharedHabitRowPreview()
        .preferredColorScheme(.dark)
}

private struct SharedHabitRowPreview: View {
    var body: some View {
        let received = ReceivedHabitsFile.demo(today: LogicalDay(.now)).habits[0]
        var withEmoji = received
        withEmoji.ownerEmoji = "😎"
        return SbuListCard([received, withEmoji].map { SharedHabitDisplay($0, now: .now) }.enumerated().map(Indexed.init)) { item in
            SharedHabitRow(display: item.display) {}
        }
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
    }

    private struct Indexed: Identifiable {
        let id: Int
        let display: SharedHabitDisplay

        init(_ pair: (offset: Int, element: SharedHabitDisplay)) {
            id = pair.offset
            display = pair.element
        }
    }
}
