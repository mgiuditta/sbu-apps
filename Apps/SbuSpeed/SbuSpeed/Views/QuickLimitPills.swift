import SbuKit
import SwiftUI

/// Four speed limits one tap away, under the trip: a tap turns one on, a tap on the one already on
/// turns it off. Any other value is in settings.
struct QuickLimitPills: View {
    let model: SpeedModel

    var body: some View {
        VStack(spacing: SbuTheme.space2) {
            Text("Limite")
                .font(SbuTheme.caption)
                .textCase(.uppercase)
                .tracking(SbuTheme.captionTracking)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: SbuTheme.space2) {
                ForEach(model.quickLimits, id: \.self) { limit in
                    QuickLimitPill(limit: limit, isOn: model.speedLimit == limit) {
                        model.toggleLimit(limit)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

/// One quick limit: the number alone, since the unit is next to the figure; VoiceOver reads it with the unit.
private struct QuickLimitPill: View {
    let limit: SpeedLimit
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(verbatim: limit.valueText())
                // Same width for 3 and 130: the row reads as a scale, not as a list of words.
                .frame(minWidth: SbuTheme.space8)
                .monospacedDigit()
        }
        .buttonStyle(SbuFieldPillStyle(isSelected: isOn))
        .accessibilityLabel(Text(verbatim: limit.text()))
    }
}

#Preview("Light") {
    QuickLimitPills(model: SpeedModel())
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentSpeed)
}

#Preview("Dark") {
    QuickLimitPills(model: SpeedModel())
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentSpeed)
        .preferredColorScheme(.dark)
}
