import SbuKit
import SwiftUI

/// The original's "Done": how many videos went to the library, the savings as the figure with
/// before and after, then what to do with the originals: delete them (danger, confirmed twice,
/// by the app and by iOS) or keep them.
struct DoneView: View {
    let model: ShrinkModel

    var body: some View {
        let summary = model.summary
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space4) {
                DoneHeader(summary: summary, access: model.access)

                SbuStat(
                    "Risparmio",
                    value: summary.savedBytes,
                    format: .size,
                    context: "\(summary.savedFraction.formatted(.percent.precision(.fractionLength(0)))) in meno"
                )

                BeforeAfterRow(before: summary.beforeBytes, after: summary.afterBytes)

                DoneNotes(summary: summary, access: model.access, deletion: model.deletion)
            }
            .padding(SbuTheme.space4)
        }
        .toolbar {
            let outputs = model.jobs.compactMap(\.output)
            if !outputs.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(items: outputs) {
                        Label("Condividi", systemImage: "square.and.arrow.up")
                    }
                    .tint(SbuTheme.ink)
                }
            }
        }
        .bottomAction {
            OriginalsActions(model: model, count: summary.deletableIDs.count)
        }
    }
}

#Preview("Light") {
    DoneView(model: .preview(videos: 5))
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentShrink)
}

#Preview("Dark") {
    DoneView(model: .preview(videos: 5, scenario: "mixed"))
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentShrink)
        .preferredColorScheme(.dark)
}
