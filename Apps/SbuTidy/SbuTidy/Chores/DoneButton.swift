import SbuKit
import SwiftUI

/// "Fatta": the swipe and menu action that marks a chore done now, in the app's accent.
struct DoneButton: View {
    let action: () -> Void

    var body: some View {
        Button("Fatta", systemImage: "checkmark", action: action)
            .tint(SbuTheme.accentTidy)
    }
}

#Preview("Light") {
    DoneButtonPreview()
}

#Preview("Dark") {
    DoneButtonPreview()
        .preferredColorScheme(.dark)
}

private struct DoneButtonPreview: View {
    var body: some View {
        List {
            Text(verbatim: "Pulire il WC")
                .swipeActions(edge: .leading) { DoneButton {} }
            DoneButton {}
        }
    }
}
