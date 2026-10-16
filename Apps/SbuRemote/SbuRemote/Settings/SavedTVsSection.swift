import SbuKit
import SwiftUI

/// The saved TVs in settings, each opening its details and "Dimentica questa TV".
struct SavedTVsSection: View {
    let session: RemoteSession

    var body: some View {
        Section {
            ForEach(session.store.tvs) { tv in
                NavigationLink {
                    SavedTVDetailView(tv: tv, session: session)
                } label: {
                    VStack(alignment: .leading, spacing: SbuTheme.space1) {
                        Text(tv.name)
                            .font(SbuTheme.body)
                            .foregroundStyle(SbuTheme.ink)
                        Text(tv.brand.displayName)
                            .font(SbuTheme.subheadline)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            if session.store.tvs.isEmpty {
                Text("Nessuna TV salvata")
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        } header: {
            Text("TV salvate")
        } footer: {
            Text("Le TV e le loro chiavi restano su questo iPhone, nel Portachiavi.")
        }
    }
}
