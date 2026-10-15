import SbuKit
import SwiftData
import SwiftUI

/// Adds or edits a gift: who, what, how much, when.
struct GiftFormView: View {
    /// The gift being edited, or `nil` for a new one.
    let editing: Gift?
    let currencyCode: String

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var person: String
    @State private var idea: String
    @State private var price: Decimal?
    @State private var hasOccasion: Bool
    @State private var occasion: Date
    @State private var isBought: Bool

    init(editing: Gift? = nil, currencyCode: String) {
        self.editing = editing
        self.currencyCode = currencyCode
        _person = State(initialValue: editing?.person ?? "")
        _idea = State(initialValue: editing?.idea ?? "")
        _price = State(initialValue: editing?.price)
        _hasOccasion = State(initialValue: editing?.occasion != nil)
        _occasion = State(initialValue: editing?.occasion ?? .now)
        _isBought = State(initialValue: editing?.isBought ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Per chi", text: $person)
                        .textContentType(.name)
                        .accessibilityIdentifier("person")
                    TextField("Idea", text: $idea)
                        .accessibilityIdentifier("idea")
                    LabeledContent("Prezzo") {
                        TextField("Prezzo", value: $price, format: .currency(code: currencyCode))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .accessibilityIdentifier("price")
                    }
                }
                Section {
                    Toggle("Occasione", isOn: $hasOccasion.animation())
                    if hasOccasion {
                        DatePicker("Data", selection: $occasion, displayedComponents: .date)
                    }
                    Toggle("Comprato", isOn: $isBought)
                }
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.surface)
            .navigationTitle(editing == nil ? "Nuovo regalo" : "Regalo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva", action: save)
                        .disabled(trimmed(idea).isEmpty)
                        .accessibilityIdentifier("save")
                }
            }
        }
    }

    private func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        let gift = editing ?? Gift(person: "", idea: "")
        gift.person = trimmed(person)
        gift.idea = trimmed(idea)
        gift.price = price
        gift.occasion = hasOccasion ? occasion : nil
        gift.isBought = isBought
        if editing == nil { modelContext.insert(gift) }
        dismiss()
    }
}

#Preview("Light") {
    GiftFormView(currencyCode: "EUR")
        .modelContainer(.duoPreview)
}

#Preview("Dark") {
    GiftFormView(currencyCode: "EUR")
        .modelContainer(.duoPreview)
        .preferredColorScheme(.dark)
}
