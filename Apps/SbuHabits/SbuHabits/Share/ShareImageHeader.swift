import SbuKit
import SwiftUI

/// The top of a shared Statistiche image: the habit's symbol and title, or Tutte le abitudini,
/// and the period under them.
struct ShareImageHeader: View {
    let share: StatisticsShare

    var body: some View {
        VStack(spacing: SbuTheme.space1) {
            HStack(spacing: SbuTheme.space2) {
                if let symbol = share.symbol {
                    Image(systemName: symbol)
                        .fontWeight(.medium)
                        .imageScale(.medium)
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                }
                Text(verbatim: share.subject())
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                    .lineLimit(2)
            }

            Text(verbatim: share.periodName())
                .font(SbuTheme.caption)
                .textCase(.uppercase)
                .tracking(SbuTheme.captionTracking)
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .multilineTextAlignment(.center)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    ShareImageHeader(share: .preview(.preview, page: 1, period: .month))
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    ShareImageHeader(share: .preview(.preview, page: 0, period: .year))
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
