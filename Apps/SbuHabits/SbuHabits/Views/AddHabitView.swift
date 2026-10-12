import SbuKit
import SwiftUI

/// The form that creates a habit: a title and a symbol.
struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss

    let model: HabitsModel

    @State private var title = ""
    @State private var symbol = HabitSymbol.all[0].id

    private var canAdd: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Titolo", text: $title)
                        .onChange(of: title, limitTitle)
                }

                Section("Simbolo") {
                    SymbolPicker(selection: $symbol)
                }
            }
            .navigationTitle("Nuova abitudine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aggiungi", action: add)
                        .disabled(canAdd == false)
                }
            }
        }
    }

    private func limitTitle() {
        if title.count > Habit.maxTitleLength {
            title = String(title.prefix(Habit.maxTitleLength))
        }
    }

    private func cancel() {
        dismiss()
    }

    private func add() {
        model.add(title: title, symbol: symbol)
        dismiss()
    }
}

#Preview("Light") {
    AddHabitView(model: .preview)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    AddHabitView(model: .preview)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
