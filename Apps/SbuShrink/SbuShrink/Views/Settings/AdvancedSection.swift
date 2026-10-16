import SbuKit
import SwiftUI

/// What the original does not have, kept out of the way: one row that says what is set and
/// opens the options on their own screen.
struct AdvancedSection: View {
    @Binding var settings: CompressionSettings
    let targetFit: TargetFit?

    var body: some View {
        Section {
            NavigationLink {
                AdvancedScreen(settings: $settings, targetFit: targetFit)
            } label: {
                LabeledContent("Avanzate") {
                    Text(verbatim: summary)
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
    }

    /// The options that differ from the defaults, and always the codec.
    private var summary: String {
        var parts: [String] = []
        if let megabytes = settings.targetMegabytes {
            parts.append(String(localized: "Max \(megabytes.formatted(.number.precision(.fractionLength(0...1)))) MB"))
        }
        parts.append(settings.codec == .h264 ? "H.264" : "HEVC")
        if settings.convertsToMP4 {
            parts.append("MP4")
        }
        if settings.removesAudio {
            parts.append(String(localized: "senza audio"))
        }
        return parts.formatted(.list(type: .and, width: .narrow))
    }
}

#Preview("Light") {
    @Previewable @State var settings = CompressionSettings(targetMegabytes: 25)
    NavigationStack {
        List {
            AdvancedSection(settings: $settings, targetFit: .fits)
        }
    }
    .tint(SbuTheme.accentShrink)
}

#Preview("Dark") {
    @Previewable @State var settings = CompressionSettings(codec: .hevc, removesAudio: true)
    NavigationStack {
        List {
            AdvancedSection(settings: $settings, targetFit: .tooSmall)
        }
    }
    .tint(SbuTheme.accentShrink)
    .preferredColorScheme(.dark)
}
