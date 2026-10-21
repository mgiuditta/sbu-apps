import SbuKit
import SwiftUI

/// The line above a Platform's page, as in SocialLite: today's time there and what was hidden.
struct UsageStrip: View {
    let minutes: Int
    let hidden: Int

    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            Text("\(Duration.seconds(minutes * 60), format: .units(allowed: [.hours, .minutes], width: .abbreviated)) oggi")
            Text(verbatim: "·")
                .accessibilityHidden(true)
            Text("Nascosti: \(hidden)")
        }
        .font(SbuTheme.footnote)
        .monospacedDigit()
        .foregroundStyle(SbuTheme.inkMuted)
        .frame(maxWidth: .infinity)
        .padding(.vertical, SbuTheme.space1)
        .background(SbuTheme.paper)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    UsageStrip(minutes: 12, hidden: 3)
}

#Preview("Dark") {
    UsageStrip(minutes: 12, hidden: 3)
        .preferredColorScheme(.dark)
}
