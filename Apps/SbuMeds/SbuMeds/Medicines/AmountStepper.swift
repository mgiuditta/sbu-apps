import SbuKit
import SwiftUI

/// How much at a time, in the form's steps and unit: "1 compressa", "2,5 ml".
struct AmountStepper: View {
    static let maxAmount = 100.0

    @Binding var amount: Double
    let form: MedicineForm

    var body: some View {
        Stepper(value: $amount, in: form.step...Self.maxAmount, step: form.step) {
            Text(verbatim: form.amountText(amount))
                .monospacedDigit()
        }
    }
}

#Preview("Light") {
    AmountStepperPreview()
}

#Preview("Dark") {
    AmountStepperPreview()
        .preferredColorScheme(.dark)
}

private struct AmountStepperPreview: View {
    @State private var amount = 1.5

    var body: some View {
        Form {
            AmountStepper(amount: $amount, form: .tablet)
        }
        .tint(SbuTheme.accentMeds)
    }
}
