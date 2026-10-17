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
                let percent = progress.fraction.formatted(.percent.precision(.fractionLength(0)))
                let context = Text("Video \(progress.current) di \(progress.total)")
                // The full stop waits: the figure is never final while the videos compress.
                SbuFigure(
                    value: percent,
                    fullStop: .waiting,
                    context: context,
                    accessibilityLabel: Text("Avanzamento, \(percent), \(context)")
                )
                .listRowInsets(EdgeInsets(top: SbuTheme.space2, leading: SbuTheme.space4, bottom: SbuTheme.space2, trailing: SbuTheme.space4))
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
        .background(SbuTheme.paper)
        .bottomAction {
            SbuButton("Interrompi", kind: .destructive, confirmationTitle: "Interrompere la compressione? I video già compressi restano in Foto.", action: model.cancel)
        }
    }
}

#Preview("Light") {
    CompressingView(model: .preview(videos: 5))
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    CompressingView(model: .preview(videos: 5))
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
