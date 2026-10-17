import SbuKit
import SwiftUI

/// The original's "Done": how many videos went to the library, the savings as the figure with
/// before and after, then what to do with the originals: delete them (danger, confirmed twice,
/// by the app and by iOS) or keep them.
///
/// The screen opens on the Closure: "Ridotto" over the savings for two seconds, once per run,
/// only when some video got lighter.
struct DoneView: View {
    let model: ShrinkModel

    @State private var isClosing = false

    var body: some View {
        let summary = model.summary
        let saved = summary.savedBytes.formatted(.size)
        let context = Text("\(summary.savedFraction.formatted(.percent.precision(.fractionLength(0)))) in meno")
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: SbuTheme.space6) {
                    DoneHeader(summary: summary, access: model.access)

                    SbuFigure(
                        value: saved,
                        context: context,
                        accessibilityLabel: Text("Risparmio, \(saved), \(context)")
                    )
                    .sbuClosure($isClosing, word: "Ridotto")

                    BeforeAfterRow(before: summary.beforeBytes, after: summary.afterBytes)

                    DoneNotes(summary: summary, access: model.access, deletion: model.deletion)
                }
                .padding(SbuTheme.space4)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .topLeading)
                // Inside the scroll, so the grid and the figure's baseline move together.
                .sbuPaper(grid: true)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(SbuTheme.paper)
        .onAppear {
            isClosing = summary.compressed > 0
        }
        .toolbar {
            let outputs = model.jobs.compactMap(\.output)
            if !outputs.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(items: outputs) {
                        Label("Condividi", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
        .bottomAction {
            OriginalsActions(model: model, count: summary.deletableIDs.count)
        }
    }
}

#Preview("Light") {
    NavigationStack {
        DoneView(model: .preview(videos: 5))
    }
    .tint(SbuTheme.ink)
    .environment(\.sbuAccent, .shrink)
}

#Preview("Dark") {
    NavigationStack {
        DoneView(model: .preview(videos: 5, scenario: "mixed"))
    }
    .tint(SbuTheme.ink)
    .environment(\.sbuAccent, .shrink)
    .preferredColorScheme(.dark)
}
