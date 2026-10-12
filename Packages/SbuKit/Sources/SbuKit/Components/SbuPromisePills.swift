import SwiftUI

/// The four promise pills of `SbuFreeBadge`. The wording is fixed: same sentences as the App Store listing.
struct SbuPromisePills: View {
    static let promises: [LocalizedStringResource] = [
        LocalizedStringResource("Nessun account", bundle: .atURL(SbuTheme.bundle.bundleURL)),
        LocalizedStringResource("Nessuna pubblicità", bundle: .atURL(SbuTheme.bundle.bundleURL)),
        LocalizedStringResource("Nessun acquisto in-app", bundle: .atURL(SbuTheme.bundle.bundleURL)),
        LocalizedStringResource("Dati solo su questo iPhone", bundle: .atURL(SbuTheme.bundle.bundleURL)),
    ]

    var body: some View {
        SbuFlowLayout(spacing: SbuTheme.space2) {
            ForEach(Self.promises, id: \.key) { promise in
                HStack(spacing: SbuTheme.space1) {
                    Circle()
                        .fill(SbuTheme.success)
                        .frame(width: SbuTheme.space2, height: SbuTheme.space2)
                        .accessibilityHidden(true)

                    Text(promise)
                        .font(SbuTheme.footnote.weight(.medium))
                        .foregroundStyle(SbuTheme.ink)
                }
                .padding(.horizontal, SbuTheme.space3)
                .padding(.vertical, SbuTheme.space1)
                .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusPill))
            }
        }
    }
}
