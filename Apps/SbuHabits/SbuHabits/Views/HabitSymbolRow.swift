import SbuKit
import SwiftUI

/// The habits' symbols under the period, in the user's order: each one turns to that habit's
/// page, the one on show filled in the accent. Centered when they fit, scrolling when not.
struct HabitSymbolRow: View {
    let habits: [Habit]
    /// The page on show: 0 for every habit, then one per habit.
    let page: Int
    let select: (Int) -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            SymbolButtons(habits: habits, page: page, select: select)
                .padding(.horizontal, SbuTheme.space4)

            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    SymbolButtons(habits: habits, page: page, select: select)
                        .padding(.horizontal, SbuTheme.space4)
                }
                .scrollIndicators(.hidden)
                .onChange(of: page, initial: true) { _, page in
                    proxy.scrollTo(page, anchor: .center)
                }
            }
        }
    }
}

private struct SymbolButtons: View {
    let habits: [Habit]
    let page: Int
    let select: (Int) -> Void

    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            ForEach(Array(habits.enumerated()), id: \.element.id) { index, habit in
                Button {
                    select(index + 1)
                } label: {
                    Label {
                        Text(habit.title)
                    } icon: {
                        Image(systemName: habit.symbol)
                    }
                }
                .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRoundSm, isProminent: page == index + 1))
                .accessibilityAddTraits(page == index + 1 ? .isSelected : [])
                .accessibilityHint(Text("Mostra le sue statistiche"))
                // The grid under the sheet has a cell with the same title.
                .accessibilityIdentifier("statistics-\(habit.title)")
                .id(index + 1)
            }
        }
        .labelStyle(.iconOnly)
    }
}

#Preview("Light") {
    HabitSymbolRow(habits: HabitsModel.preview.habits, page: 2) { _ in }
        .padding(.vertical, SbuTheme.space4)
        .background(SbuTheme.paper)
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    HabitSymbolRow(habits: HabitsModel.preview.habits, page: 0) { _ in }
        .padding(.vertical, SbuTheme.space4)
        .background(SbuTheme.paper)
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
