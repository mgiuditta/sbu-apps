import SbuKit
import SwiftUI

/// One square tab of Aggiungi abitudine: the category's symbol, filled in `ink` with `paper` when
/// chosen, sunken paper with `inkMuted` otherwise.
struct TemplateCategoryTab: View {
    let category: HabitTemplateCategory
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            Label {
                Text(category.title)
            } icon: {
                Image(systemName: category.symbol)
            }
            .labelStyle(.iconOnly)
            // As RoundButtonStyle at this side.
            .font(SbuTheme.title2)
            .fontWeight(.medium)
            .imageScale(.medium)
            // The side is fixed: past the largest text sizes the symbol would spill out.
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .foregroundStyle(isSelected ? SbuTheme.paper : SbuTheme.inkMuted)
            .frame(width: SbuTheme.controlRound, height: SbuTheme.controlRound)
            .background(isSelected ? SbuTheme.ink : SbuTheme.surfaceSunken, in: .rect(cornerRadius: SbuTheme.radiusCard))
            .contentShape(.rect(cornerRadius: SbuTheme.radiusCard))
        }
        .buttonStyle(.plain)
        // Both ways: adding no trait would leave a tab once chosen read as selected.
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityRemoveTraits(isSelected ? [] : .isSelected)
        .accessibilityShowsLargeContentViewer()
    }
}

#Preview("Light") {
    HStack {
        TemplateCategoryTab(category: .health, isSelected: true) {}
        TemplateCategoryTab(category: .toAvoid, isSelected: false) {}
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.paper)
}

#Preview("Dark") {
    HStack {
        TemplateCategoryTab(category: .health, isSelected: true) {}
        TemplateCategoryTab(category: .toAvoid, isSelected: false) {}
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.paper)
    .preferredColorScheme(.dark)
}
