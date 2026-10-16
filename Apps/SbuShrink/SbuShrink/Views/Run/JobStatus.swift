import SbuKit
import SwiftUI

/// Where a video of the run is, in words; a status color always comes with its symbol.
struct JobStatus: View {
    let job: VideoJob

    var body: some View {
        Group {
            switch job.state {
            case .loading, .waiting:
                Text("In attesa")
                    .foregroundStyle(SbuTheme.inkMuted)
            case .compressing(let fraction):
                Text(fraction, format: .percent.precision(.fractionLength(0)))
                    .monospacedDigit()
                    .foregroundStyle(SbuTheme.ink)
            case .done(let bytes, _):
                Label {
                    Text("\(job.source?.bytes ?? 0, format: .size) → \(bytes, format: .size)")
                        .monospacedDigit()
                        .foregroundStyle(SbuTheme.ink)
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(SbuTheme.success)
                        .accessibilityLabel(Text("Fatto"))
                }
            case .notSmaller:
                Text("Già leggero, resta com'è")
                    .foregroundStyle(SbuTheme.inkMuted)
            case .failed, .unreadable:
                Label("Non compresso", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(SbuTheme.danger)
            case .cancelled:
                Text("Interrotto")
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        .font(SbuTheme.footnote)
        .fontWeight(.medium)
        .labelStyle(StatusLabelStyle())
    }

    /// The status as VoiceOver reads it: words instead of the arrow.
    static func spoken(_ job: VideoJob) -> Text {
        switch job.state {
        case .loading, .waiting: Text("In attesa")
        case .compressing(let fraction): Text(fraction, format: .percent.precision(.fractionLength(0)))
        case .done(let bytes, _): Text("Fatto, da \(job.source?.bytes ?? 0, format: .size) a \(bytes, format: .size)")
        case .notSmaller: Text("Già leggero, resta com'è")
        case .failed, .unreadable: Text("Non compresso")
        case .cancelled: Text("Interrotto")
        }
    }
}

#Preview("Light") {
    VStack(alignment: .leading) {
        JobStatus(job: VideoJob(assetID: nil, source: DemoVideos.sources["IMG_1669.MOV"], state: .done(bytes: 72_300_000, saved: true)))
        JobStatus(job: VideoJob(assetID: nil, state: .failed))
    }
}

#Preview("Dark") {
    VStack(alignment: .leading) {
        JobStatus(job: VideoJob(assetID: nil, state: .compressing(0.37)))
        JobStatus(job: VideoJob(assetID: nil, state: .notSmaller))
    }
    .preferredColorScheme(.dark)
}
