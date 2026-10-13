import SbuKit
import SwiftUI

/// One sound in Gestisci: its symbol, name and group, and whether it has a heart or is hidden.
struct ManageRow: View {
    let sound: Sound
    let isFavorite: Bool
    let isHidden: Bool

    /// One column for the symbols, so the names line up.
    @ScaledMetric(relativeTo: .body) private var iconWidth = SbuTheme.space8

    var body: some View {
        HStack(spacing: SbuTheme.space3) {
            Image(systemName: sound.systemImage)
                .fontWeight(.medium)
                .frame(width: iconWidth)
                .foregroundStyle(isHidden ? SbuTheme.inkMuted : SbuTheme.ink)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                Text(sound.name)
                    .font(SbuTheme.body)
                    .foregroundStyle(isHidden ? SbuTheme.inkMuted : SbuTheme.ink)
                Text(status)
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            Spacer(minLength: 0)
            if isFavorite {
                Image(systemName: "heart.fill")
                    .fontWeight(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(isFavorite ? Text("Preferito") : Text(verbatim: ""))
    }

    /// The group, and "Nascosto" for a hidden sound.
    private var status: LocalizedStringKey {
        isHidden ? "\(Text(sound.category.title)) · Nascosto" : "\(Text(sound.category.title))"
    }
}

#Preview("Light") {
    List {
        ManageRow(sound: Sound.generated[0], isFavorite: true, isHidden: false)
        ManageRow(sound: Sound.generated[1], isFavorite: false, isHidden: true)
    }
    .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    List {
        ManageRow(sound: Sound.generated[2], isFavorite: true, isHidden: false)
    }
    .tint(SbuTheme.accentNoise)
    .preferredColorScheme(.dark)
}
