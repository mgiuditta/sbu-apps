import SbuKit
import SwiftUI

/// Dims the bedside clock, between a faint glow and full.
struct BrightnessSlider: View {
    @Binding var brightness: Double

    static let range = 0.15...1.0

    var body: some View {
        Slider(value: $brightness, in: Self.range) {
            Text("Luminosità")
        } minimumValueLabel: {
            Image(systemName: "sun.min")
                .fontWeight(.medium)
                .accessibilityHidden(true)
        } maximumValueLabel: {
            Image(systemName: "sun.max")
                .fontWeight(.medium)
                .accessibilityHidden(true)
        }
        .foregroundStyle(SbuTheme.inkMuted)
        .accessibilityValue(Text(brightness, format: .percent.precision(.fractionLength(0))))
    }
}

#Preview("Light") {
    BrightnessSlider(brightness: .constant(0.6))
        .padding(SbuTheme.space4)
}

#Preview("Dark") {
    BrightnessSlider(brightness: .constant(0.3))
        .padding(SbuTheme.space4)
        .preferredColorScheme(.dark)
}
