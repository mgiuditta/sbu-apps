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
        ValueRow(title: "Ultimo pieno", value: "6,2 L/100 km")
    }
}

#Preview("Dark") {
    List {
        ValueRow(title: "Ultimo pieno", value: "38,6 mpg", spokenValue: "38,6 miglia per gallone USA")
    }
    .preferredColorScheme(.dark)
}
