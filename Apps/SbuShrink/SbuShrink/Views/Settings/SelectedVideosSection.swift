import SbuKit
import SwiftUI

/// The picked videos as in the original: a strip of thumbnails with the weight of each, and the
/// total. Videos the iPhone cannot read are counted and left out.
struct SelectedVideosSection: View {
    let model: ShrinkModel

    var body: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: SbuTheme.space3) {
                    ForEach(model.jobs.filter { $0.state != .unreadable }) { job in
                        VideoTile(job: job)
                    }
                }
                .padding(.vertical, SbuTheme.space1)
            }
            .scrollIndicators(.hidden)
            .listRowBackground(SbuTheme.surfaceRaised)

            LabeledContent("Dimensione totale") {
                Text(model.totalBytes, format: .size)
                    .monospacedDigit()
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        } header: {
            Text("Video")
        } footer: {
            if model.isLoading {
                Text("Lettura dei video in corso")
            } else if model.unreadableCount > 0 {
                Label("Non leggibili, restano fuori: \(model.unreadableCount)", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(SbuTheme.warning)
            }
        }
    }
}

#Preview("Light") {
    List {
        SelectedVideosSection(model: .preview(videos: 5, scenario: "mixed"))
    }
}

#Preview("Dark") {
    List {
        SelectedVideosSection(model: .preview(videos: 2))
    }
    .preferredColorScheme(.dark)
}
