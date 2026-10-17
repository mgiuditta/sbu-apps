import SbuKit
import SwiftUI

/// "Ogni N giorni / settimane / mesi": a stepper for the number, a segmented picker for the unit.
struct FrequencySection: View {
    @Binding var value: Int
    @Binding var unit: FrequencyUnit

    var body: some View {
        Section("Frequenza") {
            Stepper(value: $value, in: unit.range) {
                Text(Frequency(value, unit).text)
                    .monospacedDigit()
            }
            .accessibilityIdentifier("frequencyValue")
            Picker("Unità", selection: $unit) {
                ForEach(FrequencyUnit.allCases, id: \.self) { Text($0.name).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .accessibilityIdentifier("frequencyUnit")
        }
    }
}

#Preview("Light") {
    FrequencySectionPreview()
}

#Preview("Dark") {
    FrequencySectionPreview()
        .preferredColorScheme(.dark)
}

private struct FrequencySectionPreview: View {
    @State private var value = 2
    @State private var unit = FrequencyUnit.week

    var body: some View {
        Form {
            FrequencySection(value: $value, unit: $unit)
        }
        .environment(\.sbuAccent, .tidy)
    }
}
