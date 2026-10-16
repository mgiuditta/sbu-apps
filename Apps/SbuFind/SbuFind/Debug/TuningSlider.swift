#if DEBUG
import SbuKit
import SwiftUI

/// A threshold on the Taratura screen: its name and value, and a slider.
struct TuningSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            LabeledContent {
                Text(value, format: .number.precision(.fractionLength(step < 1 ? 2 : 0)))
                    .monospacedDigit()
            } label: {
                Text(verbatim: title)
            }
            Slider(value: $value, in: range, step: step) {
                Text(verbatim: title)
            }
        }
    }
}

#Preview("Light") {
    @Previewable @State var value = -100.0
    Form {
        TuningSlider(title: "Più lontano (dBm)", value: $value, range: -120...(-70), step: 1)
    }
}

#Preview("Dark") {
    @Previewable @State var value = 0.3
    Form {
        TuningSlider(title: "Smorzamento", value: $value, range: 0.05...1, step: 0.05)
    }
    .preferredColorScheme(.dark)
}
#endif
