import SbuKit
import SwiftUI

/// A stepper for a length on the unit's step, with the length written beside the title.
/// VoiceOver hears one stepper, named by the title, valued by the length in words.
struct LengthStepper: View {
    let title: LocalizedStringResource
    @Binding var value: Double
    let unit: LengthUnit
    let range: ClosedRange<Double>

    var body: some View {
        HStack(spacing: SbuTheme.space3) {
            Text(title)
                .accessibilityHidden(true)

            Spacer(minLength: 0)

            Text(verbatim: LengthFormat.short(value, unit: unit))
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityHidden(true)

            Stepper(value: $value, in: range, step: unit.step) {
                Text(title)
            }
            .labelsHidden()
            .accessibilityValue(Text(verbatim: LengthFormat.spoken(value, unit: unit)))
        }
    }
}

#Preview("Light") {
    @Previewable @State var value = 2.0
    Form {
        LengthStepper(title: "Lato della cella", value: $value, unit: .centimeters, range: LengthUnit.centimeters.cellRange)
    }
}

#Preview("Dark") {
    @Previewable @State var value = 0.75
    Form {
        LengthStepper(title: "Lato della cella", value: $value, unit: .inches, range: LengthUnit.inches.cellRange)
    }
    .preferredColorScheme(.dark)
}
