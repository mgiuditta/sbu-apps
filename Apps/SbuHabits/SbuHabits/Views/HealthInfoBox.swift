import SbuKit
import SwiftUI

/// Under the form's preview of a habit linked to Salute: where its data comes from, and that
/// iOS may ask for access.
struct HealthInfoBox: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space3) {
            Image(systemName: "heart.fill")
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityHidden(true)
            Text("Usa i dati di Salute. Consenti l'accesso se iOS lo chiede.")
                .foregroundStyle(SbuTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(SbuTheme.subheadline)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusLg))
    }
}

#Preview("Light") {
    HealthInfoBox()
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    HealthInfoBox()
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
