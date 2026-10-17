import SbuKit
import SwiftUI

/// The original's two buttons: "Elimina originali" (danger, confirmed) and "Tieni N originali".
/// Without originals to delete, or once they are gone, only Fine.
struct OriginalsActions: View {
    let model: ShrinkModel
    let count: Int

    var body: some View {
        VStack(spacing: SbuTheme.space3) {
            if count > 0, model.deletion == .idle || model.deletion == .deleting || model.deletion == .failed {
                SbuButton("Elimina originali", kind: .destructive, confirmationTitle: "Eliminare \(count) originali? Restano in Eliminati di recente per 30 giorni.", action: deleteOriginals)
                    .disabled(model.deletion == .deleting)
                SbuButton("Tieni \(count) originali", action: model.finish)
                    .disabled(model.deletion == .deleting)
            } else {
                SbuButton("Fine", action: model.finish)
            }
        }
    }

    private func deleteOriginals() {
        Task { await model.deleteOriginals() }
    }
}

#Preview("Light") {
    OriginalsActions(model: .preview(), count: 5)
        .padding(SbuTheme.space4)
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    OriginalsActions(model: .preview(), count: 0)
        .padding(SbuTheme.space4)
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
