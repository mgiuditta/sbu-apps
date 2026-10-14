import SbuKit
import SwiftData
import SwiftUI

/// The form of a new subscription: name and price first, then how and when you pay, then how you file it.
struct SubscriptionFormView: View {
    let currency: CurrencySettings
    let onSave: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SubscriptionCategory.order) private var categories: [SubscriptionCategory]
    @Query(sort: \SubscriptionList.order) private var lists: [SubscriptionList]
    @State private var draft: SubscriptionDraft

    init(draft: SubscriptionDraft, currency: CurrencySettings, onSave: @escaping () -> Void) {
        self.currency = currency
        self.onSave = onSave
        _draft = State(initialValue: draft)
    }

    var body: some View {
        Form {
            Section {
                TextField("Nome", text: $draft.name)
                    .accessibilityIdentifier("name")
                LabeledContent("Prezzo") {
                    TextField("0", text: $draft.priceText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifier("price")
                }
                Picker("Valuta", selection: $draft.currencyCode) {
                    ForEach(CurrencySection.currencies, id: \.self) { code in
                        Text(CurrencySection.name(of: code)).tag(code)
                    }
                }
                .pickerStyle(.navigationLink)
            }

            Section("Pagamento") {
                CyclePicker(draft: $draft)
                Toggle("Prova gratuita", isOn: $draft.hasTrial)
                if draft.hasTrial {
                    DatePicker("Fine della prova", selection: $draft.trialEnd, displayedComponents: .date)
                } else {
                    DatePicker("Prossimo pagamento", selection: $draft.nextPayment, displayedComponents: .date)
                }
                if draft.cycle != .once {
                    Toggle("Numero fisso di pagamenti", isOn: $draft.hasFixedCount)
                    if draft.hasFixedCount {
                        Stepper("^[\(draft.paymentCount) pagamento](inflect: true)", value: $draft.paymentCount, in: 1...360)
                    }
                }
            }

            Section {
                Picker("Promemoria", selection: $draft.reminderDaysBefore) {
                    Text("Nessuno").tag(Int?.none)
                    Text("Il giorno stesso").tag(Int?.some(0))
                    Text("1 giorno prima").tag(Int?.some(1))
                    Text("3 giorni prima").tag(Int?.some(3))
                    Text("7 giorni prima").tag(Int?.some(7))
                }
            }

            Section("Organizza") {
                Picker("Categoria", selection: $draft.category) {
                    Text("Nessuna").tag(SubscriptionCategory?.none)
                    ForEach(categories) { category in
                        Label(category.name, systemImage: category.symbol).tag(Optional(category))
                    }
                }
                .pickerStyle(.navigationLink)
                if !lists.isEmpty {
                    Picker("Lista", selection: $draft.list) {
                        Text("Nessuna").tag(SubscriptionList?.none)
                        ForEach(lists) { list in
                            Text(list.name).tag(Optional(list))
                        }
                    }
                }
                TextField("Metodo di pagamento", text: $draft.paymentMethod)
            }

            Section {
                TextField("Sito per gestirlo", text: $draft.urlText)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Note", text: $draft.notes, axis: .vertical)
            } footer: {
                Text("Metodo di pagamento è solo un'etichetta, come «Carta personale». Non scrivere mai i dati della carta.")
            }
        }
        .navigationTitle(draft.name.isEmpty ? String(localized: "Nuovo abbonamento") : draft.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva", action: save)
                    .disabled(!draft.canSave)
                    .accessibilityIdentifier("save")
            }
        }
    }

    private func save() {
        guard let subscription = draft.makeSubscription() else { return }
        modelContext.insert(subscription)
        try? modelContext.save()
        onSave()
    }
}

#Preview("Light") {
    NavigationStack {
        SubscriptionFormView(draft: SubscriptionDraft(currencyCode: "EUR"), currency: CurrencySettings()) {}
    }
    .modelContainer(.preview)
}

#Preview("Dark") {
    NavigationStack {
        SubscriptionFormView(draft: SubscriptionDraft(currencyCode: "EUR"), currency: CurrencySettings()) {}
    }
    .modelContainer(.preview)
    .preferredColorScheme(.dark)
}
