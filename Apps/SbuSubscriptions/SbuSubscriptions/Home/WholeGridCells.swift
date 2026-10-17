import SbuKit
import SwiftUI

/// Rounds a block's height up to whole grid cells, so the figure under it starts on a grid line by itself.
///
/// In a list row SbuFigure's own snap to the grid fed the cell's self-sizing: each fraction of a point it
/// moved changed the row's height, which moved it again, and the main thread never rested. With the block
/// above it in whole cells the figure is already on a line and the snap stays at zero.
struct WholeGridCells: ViewModifier {
    @State private var height: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { newHeight in
                height = newHeight
            }
            .frame(minHeight: Self.rounded(height), alignment: .topLeading)
    }

    /// `height` rounded up to a multiple of `gridCell`.
    static func rounded(_ height: CGFloat) -> CGFloat {
        (height / SbuTheme.gridCell).rounded(.up) * SbuTheme.gridCell
    }
}

extension View {
    /// Rounds the view's height up to whole grid cells.
    func wholeGridCells() -> some View {
        modifier(WholeGridCells())
    }
}
