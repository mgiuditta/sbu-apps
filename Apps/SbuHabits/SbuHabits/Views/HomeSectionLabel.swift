import SbuKit
import SwiftUI

/// The label over a card of the tool screen, "OGGI" or "DOMANI": metadata, so IBM Plex Mono in
/// uppercase and `inkMuted`, as the cartiglio. A header for VoiceOver.
struct HomeSectionLabel: View {
    @Environment(\.locale) private var locale
    @ScaledMetric(relativeTo: .caption2) private var size = SbuTheme.cartiglioSize

    let title: LocalizedStringResource

    init(_ title: LocalizedStringResource) {
        self.title = title
    }

    var body: some View {
        // Uppercased in the string, as the cartiglio: the accessibility audit measures the string.
        Text(verbatim: String(localized: title).uppercased(with: locale))
            .font(.sbuCartiglio)
            .tracking(size * SbuTheme.cartiglioTracking)
            .foregroundStyle(SbuTheme.inkMuted)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview("Light") {
    HomeSectionLabel("Oggi")
        .padding(SbuTheme.space4)
        .sbuPaper()
}

#Preview("Dark") {
    HomeSectionLabel("Domani")
        .padding(SbuTheme.space4)
        .sbuPaper()
        .preferredColorScheme(.dark)
}
