import SbuKit
import SwiftUI

/// Nothing else heard, under your devices: one line and Cerca di nuovo. With nothing at all to
/// list, the screen shows `SbuEmpty` instead.
struct NothingNearbyRow: View {
    let searchAgain: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            Text("Nessun dispositivo vicino. Tienilo acceso e fuori dalla custodia.")
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.inkMuted)

            Button("Cerca di nuovo", action: searchAgain)
                .font(SbuTheme.body.weight(.semibold))
                .frame(minHeight: SbuTheme.controlRoundSm)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, SbuTheme.space1)
    }
}

#Preview("Light") {
    List {
        NothingNearbyRow {}
    }
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    List {
        NothingNearbyRow {}
    }
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
