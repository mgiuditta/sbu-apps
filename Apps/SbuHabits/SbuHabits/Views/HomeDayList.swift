import SbuKit
import SwiftUI

/// The lists of the tool screen, on paper: OGGI, today's habits and then the Abitudini condivise
/// received, in a card, with Aggiungi after it; DOMANI, the habits that only tomorrow asks for,
/// their boxes not to tick yet.
struct HomeDayList: View {
    let model: HabitsModel
    /// Today's places, in the user's order; Aggiungi is not one of them here.
    let slots: [HomePages.Slot]
    /// Aggiungi under the card: below the habit limit, and not while the empty state offers it.
    let canAdd: Bool
    let add: () -> Void
    let edit: (Habit) -> Void
    /// Opens today's Nota del giorno.
    let writeNote: (Habit) -> Void
    /// Opens an Abitudine condivisa received.
    let openShared: (ReceivedHabit) -> Void

    private var todaySlots: [HomePages.Slot] {
        slots.filter { $0 != .add }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            if todaySlots.isEmpty == false {
                VStack(alignment: .leading, spacing: SbuTheme.space2) {
                    HomeSectionLabel("Oggi")
                    SbuListCard(todaySlots) { slot in
                        row(for: slot)
                    }
                }
            }
            if canAdd {
                SbuButton("Aggiungi", kind: .secondary, action: add)
            } else if model.habits.count >= HomePages.habitLimit {
                // Aggiungi is gone: say why.
                Text("Hai \(HomePages.habitLimit) abitudini, il massimo. Per aggiungerne un'altra, eliminane una.")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            let tomorrow = model.tomorrowOnlyHabits
            if tomorrow.isEmpty == false {
                VStack(alignment: .leading, spacing: SbuTheme.space2) {
                    HomeSectionLabel("Domani")
                    SbuListCard(tomorrow) { habit in
                        Toggle(isOn: .constant(false)) {
                            Text(habit.title)
                                .fontWeight(.medium)
                        }
                        .toggleStyle(SbuCheckboxStyle())
                        .disabled(true)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func row(for slot: HomePages.Slot) -> some View {
        switch slot {
        case .habit(let habit):
            HabitRow(
                habit: habit,
                progress: model.progress(of: habit),
                check: model.check(of: habit),
                streak: model.streak(of: habit),
                hasNote: habit.note(on: model.today) != nil,
                fill: { model.fill(habit) },
                markDone: { model.markDone(habit) },
                undoLast: { model.undoLast(habit) },
                toggleSkip: { model.toggleSkip(habit) },
                edit: { edit(habit) },
                writeNote: { writeNote(habit) },
                startTimer: { startTimer(for: habit) }
            )
        case .shared(let received):
            SharedHabitRow(display: SharedHabitDisplay(received, now: .now)) {
                openShared(received)
            }
        case .add:
            EmptyView()
        }
    }

    private func startTimer(for habit: Habit) {
        model.startTimer(for: habit)
        // The end comes as a notification when the app is away; iOS asks only the first time.
        Task {
            _ = await ReminderScheduler.requestAuthorization()
        }
    }
}

#Preview("Light") {
    HomeDayListPreview()
}

#Preview("Dark") {
    HomeDayListPreview()
        .preferredColorScheme(.dark)
}

private struct HomeDayListPreview: View {
    @State private var model = HabitsModel.preview

    var body: some View {
        ScrollView {
            HomeDayList(model: model, slots: model.homePages.allSlots, canAdd: true, add: {}, edit: { _ in }, writeNote: { _ in }, openShared: { _ in })
                .padding(SbuTheme.space4)
        }
        .sbuPaper()
        .tint(SbuTheme.ink)
    }
}
