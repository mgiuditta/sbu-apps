import SbuKit
import SwiftUI

/// The tools under the photo, in DrawinGrid's order: grid settings, full screen.
///
/// A word beside each symbol, so nothing needs explaining; at large text sizes the pills wrap
/// onto a second row instead of cutting their words.
struct GridPills: View {
    let showGrid: () -> Void
    let showFullScreen: () -> Void

    var body: some View {
        PillsLayout(spacing: SbuTheme.space2) {
            Button("Griglia", systemImage: "square.grid.3x3", action: showGrid)
            Button("Schermo intero", systemImage: "arrow.up.left.and.arrow.down.right", action: showFullScreen)
        }
        .buttonStyle(SbuFieldPillStyle())
    }
}

#Preview("Light") {
    GridPills(showGrid: {}, showFullScreen: {})
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    GridPills(showGrid: {}, showFullScreen: {})
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
