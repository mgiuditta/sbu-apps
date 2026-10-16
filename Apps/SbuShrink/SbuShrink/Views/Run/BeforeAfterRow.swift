import SbuKit
import SwiftUI

/// The original's "Before" and "After" beside the savings, secondary to it.
struct BeforeAfterRow: View {
    let before: Int64
    let after: Int64

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title2) private var figureSize = SbuTheme.statSmallSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: SbuTheme.space3))
            : AnyLayout(HStackLayout(alignment: .top, spacing: SbuTheme.space4))
        layout {
            figure("Prima", before)
            figure("Dopo", after)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, SbuTheme.space4)
    }

    private func figure(_ label: LocalizedStringKey, _ bytes: Int64) -> some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            Text(label)
                .font(SbuTheme.caption)
                .textCase(.uppercase)
                .tracking(SbuTheme.captionTracking)
            Text(bytes, format: .size)
                .font(SbuTheme.smallNumberFont(size: figureSize))
        }
        .foregroundStyle(SbuTheme.inkMuted)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    BeforeAfterRow(before: 1_100_000_000, after: 662_800_000)
}

#Preview("Dark") {
    BeforeAfterRow(before: 1_100_000_000, after: 662_800_000)
        .preferredColorScheme(.dark)
}
