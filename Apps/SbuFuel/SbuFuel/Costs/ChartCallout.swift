import SbuKit
import SwiftUI

/// The value under your finger on a chart: the figure in ink, the date in inkMuted.
struct ChartCallout: View {
    let value: String
    let date: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value)
                .font(SbuTheme.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(SbuTheme.ink)
            Text(date)
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .padding(.horizontal, SbuTheme.space2)
        .padding(.vertical, SbuTheme.space1)
        .background(SbuTheme.surfaceSunken, in: .rect(cornerRadius: SbuTheme.radiusCard))
    }
}

#Preview("Light") {
    ChartCallout(value: "6,2 L/100 km", date: "14 mar 2026")
        .padding(SbuTheme.space4)
}

#Preview("Dark") {
    ChartCallout(value: "6,2 L/100 km", date: "14 mar 2026")
        .padding(SbuTheme.space4)
        .preferredColorScheme(.dark)
}
