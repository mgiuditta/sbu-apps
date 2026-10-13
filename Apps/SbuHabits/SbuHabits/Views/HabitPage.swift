import SbuKit
import SwiftUI

/// One page of the tool screen's grid: two columns, three rows, filled in reading order. A
/// short page keeps its empty places, so its rings stay the size of a full page's.
struct HabitPage<Cell: View>: View {
    private static var columns: Int { 2 }
    private static var rows: Int { HomePages.pageSize / columns }

    let slots: [HomePages.Slot]
    /// Builds a place from its slot.
    @ViewBuilder let cell: (HomePages.Slot) -> Cell

    var body: some View {
        Grid(horizontalSpacing: SbuTheme.space4, verticalSpacing: SbuTheme.space4) {
            ForEach(0..<Self.rows, id: \.self) { row in
                GridRow {
                    ForEach(0..<Self.columns, id: \.self) { column in
                        place(at: row * Self.columns + column)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func place(at index: Int) -> some View {
        if slots.indices.contains(index) {
            cell(slots[index])
        } else {
            Color.clear
                .accessibilityHidden(true)
        }
    }
}

#Preview("Light") {
    HabitPagePreview()
}

#Preview("Dark") {
    HabitPagePreview()
        .preferredColorScheme(.dark)
}

private struct HabitPagePreview: View {
    var body: some View {
        HabitPage(slots: [.add]) { _ in
            AddHabitCell {}
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
    }
}
