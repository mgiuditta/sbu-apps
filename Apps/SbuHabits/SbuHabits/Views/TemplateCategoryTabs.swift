import SbuKit
import SwiftUI

/// The five round tabs of Aggiungi abitudine, as Streaks has them: the chosen one filled in the
/// accent. VoiceOver reads each by its name, the chosen one as selected. The sides are fixed;
/// where five do not fit in the width, the row scrolls.
struct TemplateCategoryTabs: View {
    @Binding var selection: HabitTemplateCategory

    var body: some View {
        ViewThatFits(in: .horizontal) {
            tabs
            ScrollView(.horizontal) {
                tabs
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Categorie")
    }

    private var tabs: some View {
        HStack(spacing: SbuTheme.space3) {
            ForEach(HabitTemplateCategory.allCases, id: \.self) { category in
                TemplateCategoryTab(category: category, isSelected: category == selection) {
                    selection = category
                }
            }
        }
    }
}

#Preview("Light") {
    TemplateCategoryTabsPreview()
}

#Preview("Dark") {
    TemplateCategoryTabsPreview()
        .preferredColorScheme(.dark)
}

private struct TemplateCategoryTabsPreview: View {
    @State private var selection = HabitTemplateCategory.health

    var body: some View {
        TemplateCategoryTabs(selection: $selection)
            .padding(SbuTheme.space4)
            .background(SbuTheme.surface)
            .tint(SbuTheme.accentHabits)
    }
}
