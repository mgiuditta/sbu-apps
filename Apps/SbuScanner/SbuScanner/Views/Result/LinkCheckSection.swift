import SbuKit
import SwiftUI

/// Where a link goes, before you open it: the site's name large, the full address, and what looks wrong.
struct LinkCheckSection: View {
    let url: URL
    let check: LinkCheck

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                Text("Porta a")
                    .font(SbuTheme.caption)
                    .textCase(.uppercase)
                    .tracking(SbuTheme.captionTracking)
                    .foregroundStyle(SbuTheme.inkMuted)
                Text(verbatim: check.domain)
                    .font(SbuTheme.title2)
                    .foregroundStyle(SbuTheme.ink)
                Text(verbatim: url.absoluteString)
                    .font(SbuTheme.footnote.monospaced())
                    .foregroundStyle(SbuTheme.inkMuted)
                    .textSelection(.enabled)
            }
            .accessibilityElement(children: .combine)
            if check.warnings.isEmpty {
                Label("Nessun segnale strano nel link", systemImage: "checkmark.shield")
                    .foregroundStyle(SbuTheme.success)
            }
            ForEach(check.warnings, id: \.self) { warning in
                VStack(alignment: .leading, spacing: SbuTheme.space1) {
                    Label { Text(warning.title) } icon: { Image(systemName: "exclamationmark.triangle") }
                        .font(SbuTheme.headline)
                        .foregroundStyle(SbuTheme.warning)
                    Text(warning.explanation)
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .accessibilityElement(children: .combine)
            }
        } footer: {
            Text("Controllato sull'iPhone, solo dal testo del link: Sbu Scanner non lo apre e non lo manda a nessuno.")
        }
    }
}

#Preview("Light") {
    List {
        LinkCheckSection(url: URL(string: "http://bit.ly/abc")!, check: LinkCheck(URL(string: "http://bit.ly/abc")!)!)
    }
}

#Preview("Dark") {
    List {
        LinkCheckSection(url: URL(string: "https://sbu.dev")!, check: LinkCheck(URL(string: "https://sbu.dev")!)!)
    }
    .preferredColorScheme(.dark)
}
