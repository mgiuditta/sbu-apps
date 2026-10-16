import SbuKit
import SwiftUI

/// A secondary figure: its name in ink, the value in inkMuted with steady digits.
struct ValueRow: View {
    let title: LocalizedStringKey
    let value: String
    /// The value in full words for VoiceOver, when its unit is an abbreviation such as "mpg".
    var spokenValue: String?

    var body: some View {
        LabeledContent {
            Text(value)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
        } label: {
            Text(title)
                .foregroundStyle(SbuTheme.ink)
        }
        // One element, name and value, with the value's unit in full words.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(spokenValue ?? value)
        .listRowBackground(SbuTheme.surfaceRaised)
    }
}

#Preview("Light") {
    List {
        ValueRow(title: "Media aritmetica", value: "27,40")
    }
}

#Preview("Dark") {
    List {
        ValueRow(title: "Base di laurea", value: "101,85")
    }
    .preferredColorScheme(.dark)
}
