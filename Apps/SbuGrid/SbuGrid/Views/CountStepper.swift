import SbuKit
import SwiftUI

/// A stepper for a count, with the count the grid really has written beside the title: when
/// the count follows something else, the stepper is disabled but the number stays true.
struct CountStepper: View {
    let title: LocalizedStringResource
    @Binding var value: Int
    let range: ClosedRange<Int>
    /// The count the grid draws, which may differ from `value` while the stepper is disabled.
    let shown: Int

    var body: some View {
        // The title and the count are drawn beside the stepper and hidden from VoiceOver: the
        // stepper alone speaks, named by the title as Voice Control calls it, valued by the count.
        HStack(spacing: SbuTheme.space3) {
            Text(title)
                .accessibilityHidden(true)

            Spacer(minLength: 0)

            Text(shown, format: .number)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityHidden(true)

            Stepper(value: $value, in: range) {
                Text(title)
            }
            .labelsHidden()
            .accessibilityValue(Text(shown, format: .number))
        }
    }
}

#Preview("Light") {
    @Previewable @State var value = 4
    Form {
        CountStepper(title: "Colonne", value: $value, range: 1...50, shown: value)
    }
}

#Preview("Dark") {
    @Previewable @State var value = 4
    Form {
        CountStepper(title: "Colonne", value: $value, range: 1...50, shown: value)
    }
    .preferredColorScheme(.dark)
}
