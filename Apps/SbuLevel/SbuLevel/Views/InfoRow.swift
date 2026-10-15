import SbuKit
import SwiftUI

/// One entry of the Info page: a titled symbol in `ink`, then a short explanation in `inkMuted`.
struct InfoRow: View {
    let title: LocalizedStringKey
    let systemImage: String
    let text: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            Label {
                Text(title)
                    .font(SbuTheme.headline)
            } icon: {
                Image(systemName: systemImage)
                    .fontWeight(.medium)
                    .imageScale(.medium)
            }
            .foregroundStyle(SbuTheme.ink)

            Text(text)
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.inkMuted)
                // Every line of it, at any text size.
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, SbuTheme.space1)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    List {
        InfoRow(title: "Blocca", systemImage: "lock", text: "Ferma la cifra, così la leggi anche dopo aver tolto l'iPhone.")
    }
}

#Preview("Dark") {
    List {
        InfoRow(title: "Blocca", systemImage: "lock", text: "Ferma la cifra, così la leggi anche dopo aver tolto l'iPhone.")
    }
    .preferredColorScheme(.dark)
}
