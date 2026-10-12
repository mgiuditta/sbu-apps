import SbuKit
import SwiftUI

/// One value of the trip: an uppercase caption over the value, both secondary in `inkMuted`.
struct TripValue: View {
    let label: LocalizedStringKey
    let value: String

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
        .accessibilityElement(children: .combine)
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
