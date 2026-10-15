import SbuKit
import SwiftUI

/// One value of the trip, or of the latest fix: an uppercase caption over the value, both secondary in `inkMuted`.
struct TripValue: View {
    let label: LocalizedStringKey
    /// What VoiceOver reads instead of `label`, when the label is an abbreviation like COG.
    var spokenLabel: LocalizedStringKey?
    let value: String
    /// What VoiceOver reads instead of `value`, when the value on screen reads badly aloud, like a clock.
    var spokenValue: String?

    @ScaledMetric(relativeTo: .title2) private var valueSize = SbuTheme.statSmallSize

    var body: some View {
        VStack(spacing: SbuTheme.space1) {
            Text(label)
                .font(SbuTheme.caption)
                .textCase(.uppercase)
                .tracking(SbuTheme.captionTracking)

            Text(value)
                .font(SbuTheme.smallNumberFont(size: valueSize))
                .contentTransition(.numericText())
        }
        .foregroundStyle(SbuTheme.inkMuted)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel ?? label)
        .accessibilityValue(spokenValue ?? value)
    }
}

#Preview("Light") {
    TripValue(label: "Massima", value: "87 km/h")
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    TripValue(label: "Massima", value: "87 km/h")
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
