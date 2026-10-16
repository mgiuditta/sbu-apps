import SbuKit
import SwiftUI

/// The tool screen before the first TV: what the app needs, and the one button that starts.
struct NoTVView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: SbuTheme.space6) {
            Spacer()
            Image(systemName: "tv")
                .font(SbuTheme.largeTitle)
                .fontWeight(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityHidden(true)
            VStack(spacing: SbuTheme.space2) {
                Text("Nessuna TV")
                    .font(SbuTheme.title2)
                    .foregroundStyle(SbuTheme.ink)
                Text("Accendi la TV e collega il telefono alla stessa Wi-Fi. Sbu Remote la cerca e la comanda da qui.")
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            SbuButton("Aggiungi una TV", action: onAdd)
        }
        .padding(SbuTheme.space4)
    }
}

#Preview("Light") {
    NoTVView {}
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentRemote)
}

#Preview("Dark") {
    NoTVView {}
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentRemote)
        .preferredColorScheme(.dark)
}
