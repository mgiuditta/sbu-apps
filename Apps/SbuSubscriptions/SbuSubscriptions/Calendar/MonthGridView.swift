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

    var body: some View {
        // A plain Grid, not a lazy one: at most 42 days, and a lazy grid inside a List row asserts in
        // UICollectionView when the row first lays out during a tab switch.
        Grid(horizontalSpacing: 0, verticalSpacing: SbuTheme.space1) {
            GridRow {
                ForEach(Array(grid.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(SbuTheme.caption)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                }
            }
            ForEach(weeks, id: \.self) { start in
                GridRow {
                    ForEach(start..<min(start + 7, grid.cells.count), id: \.self) { index in
                        if let day = grid.cells[index] {
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
            }
        }
        .gesture(DragGesture(minimumDistance: 30).onEnded { value in
            if value.translation.width < -60 { changeMonth(1) }
            if value.translation.width > 60 { changeMonth(-1) }
        })
    }

    /// The index of each week's first cell.
    private var weeks: [Int] {
        Array(stride(from: 0, to: grid.cells.count, by: 7))
    }
}
