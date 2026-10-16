import SbuKit
import SwiftUI

/// The original's "Compressing Videos": the overall percentage, "video N di M", a row per video
/// with its bar, and the button that stops. Videos already done stay in Photos.
struct CompressingView: View {
    let model: ShrinkModel

    var body: some View {
        let progress = model.progress
        List {
            Section {
                SbuStat(
                    "Avanzamento",
                    value: progress.fraction,
                    format: .percent.precision(.fractionLength(0)),
                    context: "Video \(progress.current) di \(progress.total)"
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section {
                ForEach(model.readyJobs) { job in
                    JobRow(job: job)
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .bottomAction {
            SbuButton("Interrompi", kind: .destructive, confirmationTitle: "Interrompere la compressione? I video già compressi restano in Foto.", action: model.cancel)
        }
    }
}

#Preview("Light") {
    CompressingView(model: .preview(videos: 5))
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentShrink)
}

#Preview("Dark") {
    CompressingView(model: .preview(videos: 5))
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentShrink)
        .preferredColorScheme(.dark)
}
