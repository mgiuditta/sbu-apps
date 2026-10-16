import SbuKit
import SwiftUI

/// Nothing heard: a symbol, one line, and Cerca di nuovo, in the style of ContentUnavailableView.
struct NothingNearbyRow: View {
    let searchAgain: () -> Void

    var body: some View {
        VStack(spacing: SbuTheme.space3) {
            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .font(SbuTheme.title2)
                .fontWeight(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityHidden(true)

            Text("Nessun dispositivo vicino. Tienilo acceso e fuori dalla custodia.")
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.inkMuted)
                .multilineTextAlignment(.center)

            Button("Cerca di nuovo", action: searchAgain)
                .font(SbuTheme.body.weight(.semibold))
                .frame(minHeight: SbuTheme.controlRoundSm)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SbuTheme.space4)
    }
}

#Preview("Light") {
    List {
        NothingNearbyRow {}
    }
    .tint(SbuTheme.accentFind)
}

#Preview("Dark") {
    List {
        NothingNearbyRow {}
    }
    .tint(SbuTheme.accentFind)
    .preferredColorScheme(.dark)
}
