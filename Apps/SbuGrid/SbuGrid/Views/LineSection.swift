import SbuKit
import SwiftUI

/// The line of the grid: its color, thickness and opacity.
struct LineSection: View {
    @Binding var settings: GridSettings

    var body: some View {
        Section("Linee") {
            Picker("Colore", selection: $settings.lineTone) {
                ForEach(LineTone.allCases) { tone in
                    Text(tone.title).tag(tone)
                }
            }

            SliderRow(
                title: "Spessore",
                value: $settings.lineWidth,
                range: GridSettings.lineWidthRange,
                step: GridSettings.lineWidthStep,
                formatted: settings.lineWidth.formatted(.number.precision(.fractionLength(0...1)))
            )

            SliderRow(
                title: "Opacità",
                value: $settings.opacity,
                range: GridSettings.opacityRange,
                step: GridSettings.opacityStep,
                formatted: settings.opacity.formatted(.percent.precision(.fractionLength(0)))
            )
        }
    }
}

#Preview("Light") {
    @Previewable @State var settings = GridSettings()
    Form {
        LineSection(settings: $settings)
    }
}

#Preview("Dark") {
    @Previewable @State var settings = GridSettings()
    Form {
        LineSection(settings: $settings)
    }
    .preferredColorScheme(.dark)
}
