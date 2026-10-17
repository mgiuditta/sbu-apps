import SbuKit
import SwiftUI

/// The tools under the photo, in DrawinGrid's order: grid settings, the sheet and its crop,
/// full screen, then tracing with the camera (DrawinGrid's AR Sketch).
///
/// Two equal pills a row, a word beside each symbol so nothing needs explaining: four words do
/// not fit one row on any iPhone, and two tidy rows read better than a ragged wrap. At large
/// text sizes the words wrap inside their pill.
struct GridPills: View {
    let actions: GridActions

    var body: some View {
        VStack(spacing: SbuTheme.space2) {
            HStack(spacing: SbuTheme.space2) {
                pill("Griglia", systemImage: "square.grid.3x3", action: actions.showGrid)
                pill("Foglio", systemImage: "crop", action: actions.showPaper)
            }
            HStack(spacing: SbuTheme.space2) {
                pill("Schermo intero", systemImage: "arrow.up.left.and.arrow.down.right", action: actions.showFullScreen)
                pill("Ricalca", systemImage: "camera.viewfinder", action: actions.showTrace)
            }
        }
        // Never squeezed by the photo, which takes the height first.
        .fixedSize(horizontal: false, vertical: true)
    }

    private func pill(_ title: LocalizedStringResource, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            // Spacers, not a wide frame: the text keeps its own frame, so the audit sees it whole.
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                Label {
                    Text(title)
                } icon: {
                    Image(systemName: systemImage)
                }
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(SbuFieldPillStyle())
    }
}

#Preview("Light") {
    GridPills(actions: .preview)
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
}

#Preview("Dark") {
    GridPills(actions: .preview)
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .preferredColorScheme(.dark)
}
