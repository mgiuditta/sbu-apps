import SbuKit
import SwiftUI

/// One video of the run: the name, the bar, and where it is in words ("In attesa", the
/// percentage, "500,8 MB → 72,3 MB").
struct JobRow: View {
    let job: VideoJob

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space2) {
                    name
                    Spacer(minLength: SbuTheme.space2)
                    JobStatus(job: job)
                }
                VStack(alignment: .leading, spacing: SbuTheme.space1) {
                    name
                    JobStatus(job: job)
                }
            }

            ProgressView(value: job.state.fraction)
                .tint(job.state == .failed ? SbuTheme.danger : nil)
                .accessibilityHidden(true)
        }
        .padding(.vertical, SbuTheme.space1)
        .listRowBackground(SbuTheme.surfaceRaised)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: job.spokenName))
        .accessibilityValue(JobStatus.spoken(job))
        .accessibilityIdentifier("job")
    }

    private var name: some View {
        Text(verbatim: job.name)
            .font(SbuTheme.subheadline)
            .foregroundStyle(SbuTheme.ink)
            .lineLimit(1)
            .truncationMode(.middle)
    }
}

#Preview("Light") {
    JobRowPreview()
}

#Preview("Dark") {
    JobRowPreview()
        .preferredColorScheme(.dark)
}

private struct JobRowPreview: View {
    var body: some View {
        let source = DemoVideos.sources["IMG_1669.MOV"]
        List {
            JobRow(job: VideoJob(assetID: nil, name: "IMG_1669.MOV", source: source, state: .done(bytes: 72_300_000, saved: true)))
            JobRow(job: VideoJob(assetID: nil, name: "IMG_1620.MOV", source: source, state: .compressing(0.88)))
            JobRow(job: VideoJob(assetID: nil, name: "IMG_4180.MOV", source: source, state: .waiting))
            JobRow(job: VideoJob(assetID: nil, name: "IMG_0907.MP4", source: source, state: .notSmaller))
            JobRow(job: VideoJob(assetID: nil, name: "IMG_BROKEN.MOV", source: source, state: .failed))
            JobRow(job: VideoJob(assetID: nil, name: "IMG_2210.MOV", source: source, state: .cancelled))
        }
        .tint(SbuTheme.accentShrink)
    }
}
