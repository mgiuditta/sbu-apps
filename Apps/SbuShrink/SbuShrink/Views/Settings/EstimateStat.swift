import SbuKit
import SwiftUI

/// The figure of the settings: what the videos will weigh, with what they weigh now and the
/// share saved. The full stop waits while the videos are still being read.
struct EstimateStat: View {
    let model: ShrinkModel

    var body: some View {
        let value = model.estimatedBytes.formatted(.size)
        SbuFigure(
            value: value,
            fullStop: isEstimating ? .waiting : .set,
            context: Text(context),
            accessibilityLabel: Text("Dimensione stimata, \(value), \(Text(context))")
        )
    }

    private var isEstimating: Bool {
        model.isLoading || model.readyJobs.isEmpty
    }

    private var context: LocalizedStringKey {
        if model.readyJobs.isEmpty {
            return "Lettura dei video in corso"
        }
        let now = model.totalBytes.formatted(.size)
        let saved = model.estimatedSavedFraction.formatted(.percent.precision(.fractionLength(0)))
        return "Ora \(now), \(saved) in meno"
    }
}

#Preview("Light") {
    EstimateStat(model: .preview(videos: 3))
        .padding(SbuTheme.space4)
        .sbuPaper(grid: true)
        .environment(\.sbuAccent, .shrink)
}

#Preview("Dark") {
    EstimateStat(model: .preview(videos: 3))
        .padding(SbuTheme.space4)
        .sbuPaper(grid: true)
        .environment(\.sbuAccent, .shrink)
        .preferredColorScheme(.dark)
}
