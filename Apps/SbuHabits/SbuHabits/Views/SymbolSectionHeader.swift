import SbuKit
import SwiftUI

/// The name of a category in the symbol picker, pinned over the grid while it scrolls.
struct SymbolSectionHeader: View {
    let title: LocalizedStringResource

    var body: some View {
        HStack {
            Text(title)
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
        }
        .padding(.top, SbuTheme.space4)
        .padding(.bottom, SbuTheme.space2)
        .background(SbuTheme.surface)
    }
}

#Preview("Light") {
    SymbolSectionHeader(title: HabitSymbolCategory.health.title)
        .padding()
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    SymbolSectionHeader(title: HabitSymbolCategory.health.title)
        .padding()
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
