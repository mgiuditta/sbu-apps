import SbuKit
import SwiftData
import SwiftUI

/// The form of a new subscription: name and price first, then how and when you pay, then how you file it.
struct SubscriptionFormView: View {
    let currency: CurrencySettings
    /// The subscription being edited, or `nil` for a new one.
    let editing: Subscription?
    let onSave: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SubscriptionCategory.order) private var categories: [SubscriptionCategory]
    @Query(sort: \SubscriptionList.order) private var lists: [SubscriptionList]
    /// Optional: previews show the form without the app's reminders.
    @Environment(Reminders.self) private var reminders: Reminders?
    @Environment(\.scenePhase) private var scenePhase
    @State private var draft: SubscriptionDraft

    init(draft: SubscriptionDraft, currency: CurrencySettings, editing: Subscription? = nil, onSave: @escaping () -> Void) {
        self.currency = currency
        self.editing = editing
        self.onSave = onSave
        _draft = State(initialValue: draft)
    }

    var body: some View {
        Form {
            Section {
                FormHeader(draft: $draft)
            }

            Section {
                // With a trial, the first payment is the day it ends.
                if draft.hasTrial {
                    DatePicker("Fine della prova", selection: $draft.trialEnd, displayedComponents: .date)
                } else {
                    DatePicker("Prossimo pagamento", selection: $draft.nextPayment, displayedComponents: .date)
                }
                CyclePicker(draft: $draft, isEditing: editing != nil)
            }

            Section {
                ReminderPicker(daysBefore: $draft.reminderDaysBefore)
                if reminders?.access == .denied {
                    NotificationsDeniedRow()
                }
            }

            Section {
                if !lists.isEmpty {
                    Picker("Lista", selection: $draft.list) {
                        Text("Nessuna").tag(SubscriptionList?.none)
                        ForEach(lists) { list in
                            Text(list.name).tag(Optional(list))
                        }
                    }
                }
                Picker("Categoria", selection: $draft.category) {
                    Text("Nessuna").tag(SubscriptionCategory?.none)
                    ForEach(categories) { category in
                        Label(category.name, systemImage: category.symbol).tag(Optional(category))
                    }
                }
                .pickerStyle(.navigationLink)
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
        // On paper, as every screen.
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        // Back from the iPhone's Settings, the warning goes as soon as notifications are on.
        .task(id: scenePhase) {
            if scenePhase == .active { await reminders?.refreshAccess() }
        }
        .toolbar {
            if editing != nil {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva", action: save)
                    .disabled(!draft.canSave)
                    .accessibilityIdentifier("save")
            }
        }
    }

    private var title: String {
        if editing != nil { return String(localized: "Modifica") }
        return draft.name.isEmpty ? String(localized: "Nuovo abbonamento") : draft.name
    }

    private func save() {
        if let editing {
            draft.apply(to: editing)
        } else if let subscription = draft.makeSubscription() {
            modelContext.insert(subscription)
            subscription.record(.subscribed, date: subscription.createdAt)
        }
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
