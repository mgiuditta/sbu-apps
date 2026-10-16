import SbuKit
import SwiftUI

/// The value under your finger on a chart: the figure in ink, the exam in inkMuted.
struct ChartCallout: View {
    let value: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value)
                .font(SbuTheme.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(SbuTheme.ink)
            Text(detail)
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .padding(.horizontal, SbuTheme.space2)
        .padding(.vertical, SbuTheme.space1)
        .background(SbuTheme.surfaceSunken, in: .rect(cornerRadius: SbuTheme.radiusSm))
    }
}

#Preview("Light") {
    ChartCallout(value: "27,40", detail: "Basi di dati")
        .padding(SbuTheme.space4)
}

#Preview("Dark") {
    ChartCallout(value: "27,40", detail: "Basi di dati")
        .padding(SbuTheme.space4)
        .preferredColorScheme(.dark)
}
