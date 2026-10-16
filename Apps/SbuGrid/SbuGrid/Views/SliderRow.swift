import SbuKit
import SwiftUI

/// A titled slider with its value written on the right, read by VoiceOver as written.
struct SliderRow: View {
    let title: LocalizedStringResource
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let formatted: String

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            LabeledContent {
                Text(verbatim: formatted)
                    .monospacedDigit()
            } label: {
                Text(title)
            }

            slider
        }
        // One element for VoiceOver: the slider, named by the title and valued as written.
        .accessibilityRepresentation {
            slider
                .accessibilityValue(Text(verbatim: formatted))
        }
    }

    private var slider: some View {
        Slider(value: $value, in: range, step: step) {
            Text(title)
        }
    }
}

#Preview("Light") {
    @Previewable @State var value = 0.8
    Form {
        SliderRow(title: "Opacità", value: $value, range: 0.1...1, step: 0.05, formatted: value.formatted(.percent))
    }
}

#Preview("Dark") {
    @Previewable @State var value = 0.8
    Form {
        SliderRow(title: "Opacità", value: $value, range: 0.1...1, step: 0.05, formatted: value.formatted(.percent))
    }
    .preferredColorScheme(.dark)
}
