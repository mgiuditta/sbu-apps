import SbuKit
import SwiftUI

/// What the player shows in a category with nothing in it yet.
///
/// ponytail: not `ContentUnavailableView`, whose label (symbol and title as one element) the
/// accessibility audit reports as clipped text.
struct EmptyCategoryView: View {
    let category: PlayerCategory
    let createMix: () -> Void

    var body: some View {
        VStack(spacing: SbuTheme.space3) {
            Spacer(minLength: 0)
            Image(systemName: category.systemImage)
                .font(.largeTitle.weight(.medium))
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityHidden(true)
            Text(title)
                .font(SbuTheme.title2)
                .foregroundStyle(SbuTheme.ink)
                .accessibilityAddTraits(.isHeader)
                .fixedSize(horizontal: false, vertical: true)
            Text(message)
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
            if category == .mixes {
                Button("Crea un mix", action: createMix)
                    .frame(minHeight: SbuTheme.controlRoundSm)
                    .contentShape(.rect)
            }
            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.center)
        .padding(SbuTheme.space6)
        .frame(maxWidth: .infinity)
    }

    private var title: LocalizedStringKey {
        category == .favorites ? "Nessun preferito" : "Nessun mix"
    }

    private var message: LocalizedStringKey {
        category == .favorites
            ? "Tocca il cuore sotto un suono o un mix per ritrovarlo qui."
            : "Metti insieme fino a cinque suoni e scegli dove sentirli."
    }
}

#Preview("Light") {
    EmptyCategoryView(category: .favorites) {}
}

#Preview("Dark") {
    EmptyCategoryView(category: .mixes) {}
        .preferredColorScheme(.dark)
}
