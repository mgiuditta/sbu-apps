import SbuKit
import SwiftUI

/// The month as a grid of days under the weekday initials; swipe sideways for another month.
struct MonthGridView: View {
    let grid: MonthGrid
    let month: MonthPayments
    let today: Date
    @Binding var selected: Date
    let changeMonth: (Int) -> Void
    let addFrom: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: SbuTheme.space1) {
            ForEach(Array(grid.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(SbuTheme.caption)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityHidden(true)
            }
            ForEach(Array(grid.cells.enumerated()), id: \.offset) { _, day in
                if let day {
                    DayCell(
                        day: day,
                        payments: month.payments(on: day),
                        isToday: day == today,
                        isSelected: day == selected,
                        select: { selected = day },
                        addFromHere: { addFrom(day) }
                    )
                } else {
                    Color.clear.accessibilityHidden(true)
                }
            }
        }
        .gesture(DragGesture(minimumDistance: 30).onEnded { value in
            if value.translation.width < -60 { changeMonth(1) }
            if value.translation.width > 60 { changeMonth(-1) }
        })
    }
}
