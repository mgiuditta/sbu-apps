import SbuKit
import SwiftUI

/// One numbered step of the export how-to.
struct HelpStep: View {
    let number: Int
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space3) {
            Text(number, format: .number)
                .font(SbuTheme.headline)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
            Text(text)
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
        }
        .listRowBackground(SbuTheme.surfaceRaised)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    List { HelpStep(number: 1, text: "Apri la chat in WhatsApp e tocca il suo nome in alto.") }
}

#Preview("Dark") {
    List { HelpStep(number: 1, text: "Apri la chat in WhatsApp e tocca il suo nome in alto.") }
        .preferredColorScheme(.dark)
}
