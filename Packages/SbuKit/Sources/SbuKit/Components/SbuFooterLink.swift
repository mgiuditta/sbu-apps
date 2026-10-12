import SwiftUI

/// The "Parte di sbu.dev" footer of `SbuFreeBadge`, linking to sbu.dev.
struct SbuFooterLink: View {
    // ponytail: literal URL, always valid.
    private static let site = URL(string: "https://sbu.dev")!

    var body: some View {
        Link(destination: Self.site) {
            HStack(spacing: SbuTheme.space3) {
                SbuAppIconView(image: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle), side: 32)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Parte di sbu.dev", bundle: SbuTheme.bundle)
                        .font(SbuTheme.subheadline.weight(.semibold))
                        .foregroundStyle(SbuTheme.ink)

                    Text("App gratuite che fanno una cosa sola.", bundle: SbuTheme.bundle)
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                }

                Spacer(minLength: 0)

                Image(systemName: "arrow.up.right")
                    .fontWeight(.medium)
                    .foregroundStyle(SbuTheme.brand)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, SbuTheme.space3)
            .padding(.horizontal, SbuTheme.space4)
            .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusLg))
        }
        .accessibilityHint(Text("Apre sbu.dev in Safari", bundle: SbuTheme.bundle))
    }
}
