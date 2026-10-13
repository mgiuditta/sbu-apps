import SbuKit
import SwiftUI

/// The habit's title in capitals under the form's ring, after the heart of a habit linked to
/// Salute or the ⊘ of an Abitudine da evitare, which VoiceOver reads as words.
struct HabitPreviewTitle: View {
    let title: String
    /// `HabitDraft.titleMark`: an SF Symbol, or `nil`.
    let mark: String?

    private var markLabel: LocalizedStringKey {
        mark == "nosign" ? "Da evitare" : "Collegata a Salute"
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space2) {
            if let mark {
                Image(systemName: mark)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityLabel(markLabel)
            }
            Text(title.localizedUppercase)
                .foregroundStyle(SbuTheme.ink)
                // In capitals VoiceOver may spell it out letter by letter.
                .accessibilityLabel(title)
                .multilineTextAlignment(.center)
        }
        .font(SbuTheme.headline)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview("Light") {
    HabitPreviewTitlePreview()
}

#Preview("Dark") {
    HabitPreviewTitlePreview()
        .preferredColorScheme(.dark)
}

private struct HabitPreviewTitlePreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space4) {
            HabitPreviewTitle(title: "Camminare 8000 passi", mark: "heart.fill")
            HabitPreviewTitle(title: "Caffè", mark: "nosign")
            HabitPreviewTitle(title: "Leggere", mark: nil)
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
    }
}
