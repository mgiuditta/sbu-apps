import SbuKit
import SwiftUI

/// The Modelli a search finds, in every tab, under the tab's name; each row says its kind, so
/// the same title in two tabs reads apart.
struct TemplateSearchSections: View {
    let sections: [TemplateSearch.Section]

    var body: some View {
        ForEach(sections, id: \.category) { section in
            Section {
                ForEach(section.templates) { template in
                    NavigationLink(value: AddHabitRoute.template(template.id)) {
                        TemplateRow(title: template.title, symbol: template.symbol, linksHealth: template.health != nil, detail: template.detail)
                    }
                }
            } header: {
                Text(section.category.title)
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
    }
}

#Preview("Light") {
    TemplateSearchSectionsPreview()
}

#Preview("Dark") {
    TemplateSearchSectionsPreview()
        .preferredColorScheme(.dark)
}

private struct TemplateSearchSectionsPreview: View {
    var body: some View {
        NavigationStack {
            List {
                TemplateSearchSections(sections: TemplateSearch.sections(of: HabitTemplate.all, matching: "legg"))
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
        }
        .tint(SbuTheme.ink)
    }
}
