import SbuKit
import SwiftUI

/// A figure on a `List` row, at a height that never moves.
///
/// `SbuFigure` pads itself down to the next grid line, so its height follows where it sits; on a row
/// that height change makes the list size the row again, and under the accessibility audit the two
/// never settle. Here a hidden copy at its own origin (no snap) sets the row's height, plus one grid
/// cell for the largest snap, and the real figure is drawn over it from the top.
struct SteadyFigure<Figure: View>: View {
    /// The figure; `true` asks for the hidden copy, which must not show a `.set` full stop.
    @ViewBuilder let figure: (_ isPlaceholder: Bool) -> Figure

    var body: some View {
        figure(true)
            // Its own paper space: the copy sits on a grid line and never snaps.
            .sbuPaper(grid: false)
            .hidden()
            .accessibilityHidden(true)
            .padding(.bottom, SbuTheme.gridCell)
            .overlay(alignment: .top) {
                figure(false)
            }
    }
}

#Preview("Light") {
    List {
        SteadyFigure { isPlaceholder in
            SbuFigure(value: 12.formatted(), fullStop: isPlaceholder ? .absent : .set)
        }
        .padding(SbuTheme.space4)
        .sbuPaper(grid: true)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
    .environment(\.sbuAccent, .inventory)
}

#Preview("Dark") {
    List {
        SteadyFigure { isPlaceholder in
            SbuFigure(value: 0.formatted(), fullStop: isPlaceholder ? .absent : .waiting)
        }
        .padding(SbuTheme.space4)
        .sbuPaper(grid: true)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
    .preferredColorScheme(.dark)
}
