import SbuKit
import SwiftUI

/// One of the original's slider cards: the name and value on a line, the slider, the advice
/// under it.
struct SettingSliderSection: View {
    let title: LocalizedStringKey
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let valueText: Text
    let hint: LocalizedStringKey

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                LabeledContent {
                    valueText
                        .monospacedDigit()
                        .foregroundStyle(SbuTheme.ink)
                } label: {
                    Text(title)
                        .foregroundStyle(SbuTheme.ink)
                }
                .font(SbuTheme.headline)
                .accessibilityHidden(true)

                // No `step:` on the slider: iOS 26 draws a tick for each step, a row of dots at 1 fps.
                Slider(value: sliderValue, in: Double(range.lowerBound)...Double(range.upperBound)) {
                    Text(title)
                }
                .accessibilityValue(valueText)
                .accessibilityAdjustableAction(adjust)
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        } footer: {
            Text(hint)
        }
    }

    /// VoiceOver moves by one step, as the slider does by touch.
    private func adjust(_ direction: AccessibilityAdjustmentDirection) {
        switch direction {
        case .increment: value = (value + step).clamped(to: range)
        case .decrement: value = (value - step).clamped(to: range)
        @unknown default: break
        }
    }

    private var sliderValue: Binding<Double> {
        Binding {
            Double(value)
        } set: { newValue in
            let stepped = (newValue / Double(step)).rounded() * Double(step)
            value = Int(stepped).clamped(to: range)
        }
    }
}

#Preview("Light") {
    @Previewable @State var value = 80
    List {
        SettingSliderSection(title: "Dimensioni", value: $value, range: 10...100, step: 5, valueText: Text("\(value)%"), hint: "Ti consigliamo l'80%.")
    }
    .tint(SbuTheme.accentShrink)
}

#Preview("Dark") {
    @Previewable @State var value = 24
    List {
        SettingSliderSection(title: "Frame rate", value: $value, range: 10...60, step: 1, valueText: Text("\(value) fps"), hint: "Ti consigliamo di non scendere sotto 24.")
    }
    .tint(SbuTheme.accentShrink)
    .preferredColorScheme(.dark)
}
