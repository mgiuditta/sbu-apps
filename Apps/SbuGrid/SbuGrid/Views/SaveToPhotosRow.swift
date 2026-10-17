import SbuKit
import SwiftUI

/// The button that saves to Photos, which then says it saved, with a word and a symbol.
struct SaveToPhotosRow: View {
    let state: SaveState
    let action: () -> Void

    var body: some View {
        switch state {
        case .idle:
            Button("Salva in Foto", systemImage: "square.and.arrow.down", action: action)
        case .saving:
            Label {
                Text("Salvataggio in Foto")
            } icon: {
                ProgressView()
            }
            .foregroundStyle(SbuTheme.inkMuted)
        case .saved:
            // In ink: the one color is the full stop's, and the word says it.
            Label("Salvata in Foto", systemImage: "checkmark.circle")
                .foregroundStyle(SbuTheme.ink)
        case .failed:
            Button(action: action) {
                Label("Non salvata. Riprova", systemImage: "exclamationmark.triangle")
            }
            .foregroundStyle(SbuTheme.danger)
        }
    }
}

#Preview("Light") {
    Form {
        SaveToPhotosRow(state: .idle) {}
        SaveToPhotosRow(state: .saving) {}
        SaveToPhotosRow(state: .saved) {}
        SaveToPhotosRow(state: .failed) {}
    }
}

#Preview("Dark") {
    Form {
        SaveToPhotosRow(state: .idle) {}
        SaveToPhotosRow(state: .saved) {}
    }
    .preferredColorScheme(.dark)
}
