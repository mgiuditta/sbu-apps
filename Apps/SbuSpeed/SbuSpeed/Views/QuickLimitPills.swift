import SbuKit
import SwiftUI

/// Four speed limits one tap away, under the trip: a tap turns one on, a tap on the one already on
/// turns it off. Any other value is in settings.
struct QuickLimitPills: View {
    let model: SpeedModel

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Four in a row, two by two at accessibility text sizes.
    private var rows: [[SpeedLimit]] {
        let limits = model.quickLimits
        guard dynamicTypeSize.isAccessibilitySize else { return [limits] }
        return stride(from: 0, to: limits.count, by: 2).map { Array(limits[$0..<min($0 + 2, limits.count)]) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            Text("Limite")
                .font(SbuTheme.caption)
                .textCase(.uppercase)
                .tracking(SbuTheme.captionTracking)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityAddTraits(.isHeader)

            ForEach(rows, id: \.self) { row in
                HStack(spacing: SbuTheme.space2) {
                    ForEach(row, id: \.self) { limit in
                        QuickLimitPill(limit: limit, isOn: model.speedLimit == limit) {
                            model.toggleLimit(limit)
                        }
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
        .sbuPaper()
}

#Preview("Dark") {
    QuickLimitPills(model: SpeedModel())
        .padding(SbuTheme.space4)
        .sbuPaper()
        .preferredColorScheme(.dark)
}
