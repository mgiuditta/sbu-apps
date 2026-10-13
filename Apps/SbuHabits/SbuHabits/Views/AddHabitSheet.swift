import SbuKit
import SwiftUI

/// Aggiungi abitudine, as Streaks has it: Chiudi, the search behind the lens, five tabs of
/// Modelli and a Personalizzata habit for each. A row pushes the habit form, filled in; saving
/// it closes the sheet.
struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss

    let model: HabitsModel

    @State private var category = HabitTemplateCategory.general
    @State private var query = ""
    @State private var isSearching = false

    var body: some View {
        let results = TemplateSearch.sections(of: HabitTemplate.all, matching: query)
        let showsResults = isSearching && SymbolSearch.terms(in: [query]).isEmpty == false
        NavigationStack {
            List {
                if showsResults {
                    TemplateSearchSections(sections: results)
                } else {
                    TemplateCategorySections(category: $category)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .background(SbuTheme.surface)
            .overlay {
                if showsResults, results.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .navigationTitle("Aggiungi abitudine")
            .navigationBarTitleDisplayMode(.inline)
            .modifier(RevealedSearch(isPresented: $isSearching, text: $query, prompt: Text("Cerca un modello")))
            .onChange(of: isSearching, clearQuery)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi", systemImage: "xmark", action: close)
                }
                if isSearching == false {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Cerca", systemImage: "magnifyingglass", action: search)
                    }
                }
            }
            .navigationDestination(for: AddHabitRoute.self, destination: form)
        }
    }

    private func form(for route: AddHabitRoute) -> some View {
        HabitFormScreen(model: model, draft: route.draft(today: model.today, canLinkHealth: model.isHealthAvailable), close: close)
    }

    private func search() {
        isSearching = true
    }

    private func clearQuery() {
        if isSearching == false {
            query = ""
        }
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    AddHabitSheet(model: .preview)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    AddHabitSheet(model: .preview)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
