import SbuKit
import SwiftUI

/// One numbered step of a guide: the number, the sentence, the step's symbol.
struct GuideStepRow: View {
    let number: Int
    let step: HelpItem

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space3) {
            Text(number, format: .number)
                .font(SbuTheme.headline.monospacedDigit())
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityLabel(Text("Passo \(number)"))

            Text(step.text)
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: step.systemImage)
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    List {
        GuideStepRow(number: 1, step: AirPodGuide.steps[0])
    }
    .tint(SbuTheme.accentFind)
}

#Preview("Dark") {
    List {
        GuideStepRow(number: 2, step: AirPodGuide.steps[1])
    }
    .tint(SbuTheme.accentFind)
    .preferredColorScheme(.dark)
}
