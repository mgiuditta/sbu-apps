import SbuKit
import SwiftUI

/// The sheet that chooses a habit's symbol: every symbol of the catalog by category, with a
/// search in Italian and English. Choosing one closes the sheet; the chosen one sits on the accent.
struct SymbolPicker: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selection: String

    @State private var query = ""
    /// The cells grow with Dynamic Type, so fewer fit on a row.
    @ScaledMetric(relativeTo: .title2) private var cellWidth = SbuTheme.space12

    var body: some View {
        let sections = SymbolSearch.sections(of: HabitSymbol.all, matching: query)
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: cellWidth), spacing: SbuTheme.space2)], spacing: SbuTheme.space2, pinnedViews: .sectionHeaders) {
                    ForEach(sections, id: \.category) { section in
                        Section {
                            ForEach(section.symbols) { symbol in
                                SymbolButton(symbol: symbol, isSelected: symbol.id == selection) {
                                    choose(symbol)
                                }
                            }
                        } header: {
                            SymbolSectionHeader(title: section.category.title)
                        }
                    }
                }
                .padding(.horizontal, SbuTheme.space4)
                .padding(.bottom, SbuTheme.space4)
            }
            .scrollDismissesKeyboard(.immediately)
            .overlay {
                if sections.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .background(SbuTheme.paper)
            .navigationTitle("Simbolo")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Cerca un simbolo"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: cancel)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func choose(_ symbol: HabitSymbol) {
        selection = symbol.id
        dismiss()
    }

    private func cancel() {
        dismiss()
    }
}

#Preview("Light") {
    SymbolPickerPreview()
}

#Preview("Dark") {
    SymbolPickerPreview()
        .preferredColorScheme(.dark)
}

private struct SymbolPickerPreview: View {
    @State private var selection = "book"

    var body: some View {
        Color.clear
            .sheet(isPresented: .constant(true)) {
                SymbolPicker(selection: $selection)
            }
            .tint(SbuTheme.ink)
    }
}
