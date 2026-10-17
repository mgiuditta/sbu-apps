import SbuKit
import SwiftUI

/// A secondary figure: its name in ink, the value in inkMuted with steady digits.
struct ValueRow: View {
    let title: LocalizedStringKey
    let value: String
    /// The value in full words for VoiceOver, when its unit is an abbreviation such as "mpg".
    var spokenValue: String?

    init(title: LocalizedStringKey, value: String, spokenValue: String? = nil) {
        self.title = title
        self.value = value
        self.spokenValue = spokenValue
    }

    init(_ value: OverviewValue) {
        self.init(title: value.title, value: value.value, spokenValue: value.spokenValue)
    }

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
        // In the List of Spese e grafici; in a card on paper it has no effect.
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
