import SbuKit
import SwiftUI

/// Today's habits on the tool screen, as Streaks lays them out: pages of two columns and three
/// rows that swipe sideways, Aggiungi in the last place. At accessibility text sizes the pages
/// give way to one column that scrolls, rings and text growing with the text size.
///
/// Every page is built, not lazily: all habits stay in the accessibility tree, so VoiceOver
/// swipes through them in order and the grid scrolls to the page of the one it reaches.
struct HabitGrid: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: HabitsModel
    let pages: HomePages
    /// The page on screen; `nil` while a swipe is between two.
    @Binding var page: Int?
    let add: () -> Void
    let edit: (Habit) -> Void
    /// Opens today's Nota del giorno.
    var writeNote: (Habit) -> Void = { _ in }
    /// Opens an Abitudine condivisa received.
    var openShared: (ReceivedHabit) -> Void = { _ in }

    @ScaledMetric(relativeTo: .title2) private var columnRingSide = SbuTheme.space12 * 2

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            ScrollView {
                // Not lazy: a lazy stack drops the rows that grow past the screen with larger
                // text, and their text stops scaling with it (#97).
                VStack(spacing: SbuTheme.space6) {
                    ForEach(pages.allSlots) { slot in
                        cell(for: slot, maxRingSide: columnRingSide)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicatorsFlash(onAppear: true)
        } else {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(pages.pages.indices, id: \.self) { index in
                        HabitPage(slots: pages.pages[index]) { slot, row in
                            cell(for: slot, maxRingSide: .infinity, rowCaptions: row.map(caption(of:)))
                        }
                        // Pages run edge to edge under the finger, the rings keep the margins.
                        .padding(.horizontal, SbuTheme.space4)
                        .containerRelativeFrame(.horizontal)
                        .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $page)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            .padding(.horizontal, -SbuTheme.space4)
        }
    }

    @ViewBuilder
    private func cell(for slot: HomePages.Slot, maxRingSide: CGFloat, rowCaptions: [SlotCaption] = []) -> some View {
        switch slot {
        case .habit(let habit):
            HabitCell(
                habit: habit,
                progress: model.progress(of: habit),
                streak: model.streak(of: habit),
                hasNote: hasNote(habit),
                maxRingSide: maxRingSide,
                rowCaptions: rowCaptions,
                markDone: { model.markDone(habit) },
                undoLast: { model.undoLast(habit) },
                toggleSkip: { model.toggleSkip(habit) },
                edit: { edit(habit) },
                writeNote: { writeNote(habit) },
                startTimer: { startTimer(for: habit) }
            )
        case .shared(let received):
            SharedHabitCell(display: SharedHabitDisplay(received, now: .now), maxRingSide: maxRingSide, rowCaptions: rowCaptions) {
                openShared(received)
            }
        case .add:
            AddHabitCell(maxRingSide: maxRingSide, rowCaptions: rowCaptions, add: add)
        }
    }

    private func caption(of slot: HomePages.Slot) -> SlotCaption {
        switch slot {
        case .habit(let habit): HabitCell.caption(of: habit, hasNote: hasNote(habit))
        case .shared(let received): SharedHabitCell.caption(of: SharedHabitDisplay(received, now: .now))
        case .add: AddHabitCell.caption
        }
    }

    private func hasNote(_ habit: Habit) -> Bool {
        habit.note(on: model.today) != nil
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
    HabitGridPreview()
}

#Preview("Dark") {
    HabitGridPreview()
        .preferredColorScheme(.dark)
}

private struct HabitGridPreview: View {
    @State private var model = HabitsModel.preview
    @State private var page: Int? = 0

    var body: some View {
        HabitGrid(model: model, pages: model.homePages, page: $page, add: {}, edit: { _ in })
            .padding(SbuTheme.space4)
            .background(SbuTheme.surface)
            .tint(SbuTheme.accentHabits)
    }
}
