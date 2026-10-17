import SbuKit
import SwiftUI

/// Aggiungi abitudine without a search: the tabs, what the chosen one means, Personalizzata,
/// then the tab's Modelli.
struct TemplateCategorySections: View {
    @Binding var category: HabitTemplateCategory

    var body: some View {
        Section {
            TemplateCategoryTabs(selection: $category)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
        } footer: {
            Text(category.explanation)
        }

        Section {
            NavigationLink(value: AddHabitRoute.custom(category)) {
                TemplateRow(title: "Personalizzata", symbol: "plus")
            }
        }
        .listRowBackground(SbuTheme.surfaceRaised)

        Section {
            ForEach(HabitTemplate.of(category)) { template in
                NavigationLink(value: AddHabitRoute.template(template.id)) {
                    TemplateRow(title: template.title, symbol: template.symbol, linksHealth: template.health != nil)
                }
            }
        } header: {
            Text(category.header)
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }
}

#Preview("Light") {
    TemplateCategorySectionsPreview()
}

#Preview("Dark") {
    TemplateCategorySectionsPreview()
        .preferredColorScheme(.dark)
}

private struct TemplateCategorySectionsPreview: View {
    @State private var category = HabitTemplateCategory.health

    var body: some View {
        NavigationStack {
            List {
                TemplateCategorySections(category: $category)
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
        }
        .tint(SbuTheme.ink)
    }
}
