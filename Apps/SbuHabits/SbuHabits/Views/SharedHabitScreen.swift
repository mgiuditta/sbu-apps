import SbuKit
import SwiftUI

/// An Abitudine condivisa received, as Streaks shows it: its ring and title, the box that says it
/// is shared with you, the row of icons for its owner, then its statistics, read only, with the
/// completion rate as the one figure. Rimuovi takes it off this iPhone and leaves the share.
struct SharedHabitScreen: View {
    @Environment(\.dismiss) private var dismiss

    let received: ReceivedHabits
    /// The habit's key: the screen follows its latest copy, and closes once it is gone.
    let key: String

    /// The preview ring is not scaled: it is a picture, hidden from VoiceOver.
    private let ringSize = SbuTheme.space12 * 3

    private var habit: ReceivedHabit? {
        received.habits.first { $0.key == key }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let habit {
                    content(of: habit)
                }
            }
            .background(SbuTheme.paper)
            .navigationTitle("Abitudine condivisa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine", action: close)
                }
            }
        }
        // Removed here, or no longer shared after a refresh.
        .onChange(of: habit == nil) { _, isGone in
            if isGone {
                close()
            }
        }
    }

    private func content(of received: ReceivedHabit) -> some View {
        let display = SharedHabitDisplay(received, now: .now)
        let statistics = HabitStatistics.habit(display.habit, period: .all, today: display.today, firstWeekday: Calendar.current.firstWeekday)
        return ScrollView {
            VStack(spacing: SbuTheme.space6) {
                VStack(spacing: SbuTheme.space3) {
                    HabitRing(face: display.face, symbolFont: SbuTheme.largeTitle)
                        .frame(width: ringSize, height: ringSize)
                        .accessibilityHidden(true)
                    HabitPreviewTitle(title: display.habit.title, mark: nil)
                        .accessibilityAddTraits(.isHeader)
                }

                SharedHabitInfoBox()

                OwnerEmojiPicker(selection: display.ownerEmoji) { emoji in
                    self.received.setOwnerEmoji(emoji, for: received)
                }

                StatisticsFigure(statistics: statistics, streakSchedule: display.habit.schedule, showsFullStop: true)

                CompletionLineChart(statistics: statistics)

                CompletionsSection(statistics: statistics, isAvoided: display.habit.limit != nil)

                HabitHistorySection(habit: display.habit, streak: display.streak, today: display.today, firstWeekday: Calendar.current.firstWeekday, openNote: nil)

                SbuButton("Rimuovi", kind: .destructive, confirmationTitle: "Rimuovere “\(display.habit.title)”?") {
                    remove(received)
                }

                Text("Se la rimuovi, sparisce da questo iPhone. Chi la condivide non perde niente.")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.vertical, SbuTheme.space6)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private func remove(_ habit: ReceivedHabit) {
        Task {
            await received.remove(habit)
        }
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    let received = ReceivedHabits.preview
    SharedHabitScreen(received: received, key: received.habits[0].key)
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    let received = ReceivedHabits.preview
    SharedHabitScreen(received: received, key: received.habits[0].key)
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
