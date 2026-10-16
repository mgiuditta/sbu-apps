import SbuKit
import SwiftUI

/// The figure of the settings: what the videos will weigh, with what they weigh now and the
/// share saved.
struct EstimateStat: View {
    let model: ShrinkModel

    var body: some View {
        SbuStat("Dimensione stimata", value: model.estimatedBytes, format: .size, context: context)
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
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentShrink)
}

#Preview("Dark") {
    EstimateStat(model: .preview(videos: 3))
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentShrink)
        .preferredColorScheme(.dark)
}
