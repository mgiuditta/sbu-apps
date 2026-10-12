import SwiftUI

/// Settings → Licenze: the notices of the third-party fonts SbuKit ships, as their licences ask.
///
/// Today only Bricolage Grotesque, under the SIL Open Font License 1.1. The notice is shown as
/// written, in English, copyright line first.
struct SbuLicensesView: View {
    /// The OFL notice bundled next to the font, or empty if the file is missing.
    private let notice: String = {
        guard let url = SbuFont.licenseURL else { return "" }
        return (try? String(contentsOf: url, encoding: .utf8)) ?? ""
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                Text(verbatim: "Bricolage Grotesque")
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                    .accessibilityAddTraits(.isHeader)

                Text(verbatim: notice)
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(SbuTheme.space4)
        }
        .background(SbuTheme.surface)
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
