// iOS only: the shell, the settings and list rows have no place on Apple Watch.
#if os(iOS)

import SwiftUI

/// Settings → Licenze: the notices of the third-party fonts SbuKit ships, as their licences ask.
///
/// Bricolage Grotesque and IBM Plex Mono, both under the SIL Open Font License 1.1. Each notice is
/// shown as written, in English, copyright line first.
struct SbuLicensesView: View {
    /// The fonts and their OFL notices bundled next to them, paragraphs reflowed to the screen's
    /// width; a missing file shows an empty notice.
    private let fonts: [(name: String, notice: String)] = [
        ("Bricolage Grotesque", SbuFont.licenseURL),
        ("IBM Plex Mono", SbuFont.monoLicenseURL),
    ].map { name, url in
        let text = url.flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? ""
        return (name, SbuLicenseText.reflowed(text))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                ForEach(fonts, id: \.name) { font in
                    VStack(alignment: .leading, spacing: SbuTheme.space2) {
                        Text(verbatim: font.name)
                            .font(SbuTheme.headline)
                            .foregroundStyle(SbuTheme.ink)
                            .accessibilityAddTraits(.isHeader)

                        Text(verbatim: font.notice)
                            .font(SbuTheme.footnote)
                            .foregroundStyle(SbuTheme.inkMuted)
                            .textSelection(.enabled)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(SbuTheme.space4)
        }
        .background(SbuTheme.paper)
        .navigationTitle(Text("Licenze", bundle: SbuTheme.bundle))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    NavigationStack {
        SbuLicensesView()
    }
}

#Preview("Dark") {
    NavigationStack {
        SbuLicensesView()
    }
    .preferredColorScheme(.dark)
}

#endif
