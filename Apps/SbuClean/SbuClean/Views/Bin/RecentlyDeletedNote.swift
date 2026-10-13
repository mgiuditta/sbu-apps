import SbuKit
import SwiftUI

/// The honest note about Recently Deleted: the space comes back only after 30 days, or when
/// the user empties that album in Photos.
struct RecentlyDeletedNote: View {
    var body: some View {
        Label {
            Text("iOS tiene le foto eliminate per 30 giorni nell'album Eliminati di recente, nell'app Foto. Lo spazio torna dopo 30 giorni, o subito se le elimini anche da lì.")
        } icon: {
            Image(systemName: "info.circle")
                .fontWeight(.medium)
        }
        .font(SbuTheme.footnote)
        .foregroundStyle(SbuTheme.inkMuted)
    }
}

#Preview("Light") {
    RecentlyDeletedNote()
        .padding()
}

#Preview("Dark") {
    RecentlyDeletedNote()
        .padding()
        .preferredColorScheme(.dark)
}
