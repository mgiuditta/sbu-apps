import SbuKit
import SwiftData
import SwiftUI

/// Medisafe's medicine screen: doses taken in the last 30 days as the figure, the next dose, the
/// schedule, the stock with "Ricarica", an extra dose, the notes and the history.
struct MedicineView: View {
    static let figureDays = 30

    let medicine: Medicine

    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @Environment(Clock.self) private var clock
    @State private var isEditing = false
    @State private var isRefilling = false
    @State private var takeCount = 0

    var body: some View {
        // A medicine deleted from its form is gone before the screen is.
        if medicine.isDeleted || medicine.modelContext == nil {
            Color.clear
        } else {
            content
        }
    }

    private var content: some View {
        let snapshot = medicine.snapshot
        let today = Day(clock.now, calendar: calendar)
        let adherence = Adherence([snapshot], from: today.adding(days: -(Self.figureDays - 1), in: calendar), through: today, now: clock.now, calendar: calendar)
        return List {
            Section {
                MedicineFigure(adherence: adherence)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            MedicineScheduleSection(medicine: snapshot)
            if snapshot.stockLevel.isTracked {
                MedicineStockSection(medicine: snapshot, refill: refill)
            }
            Section {
                SbuButton("Prendi una dose extra", kind: .secondary, action: takeExtra)
                    .accessibilityIdentifier("takeExtra")
            } footer: {
                Text(verbatim: String(localized: "Fuori orario, ora: \(snapshot.form.amountText(extraAmount)). Resta nello storico."))
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            if !medicine.notes.isEmpty {
                Section("Note") {
                    Text(medicine.notes)
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.ink)
                        .textSelection(.enabled)
                        .listRowBackground(SbuTheme.surfaceRaised)
                }
            }
            MedicineHistorySection(medicine: medicine)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .navigationTitle(medicine.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Modifica", action: edit)
                    .accessibilityIdentifier("editMedicine")
            }
        }
        .sheet(isPresented: $isEditing) {
            if let person = medicine.person {
                MedicineEditor(person: person, medicine: medicine)
            }
        }
        .sheet(isPresented: $isRefilling) {
            RefillSheet(form: medicine.form) { quantity in
                Cabinet.refill(medicine, adding: quantity)
                try? modelContext.save()
            }
        }
        .sbuAffectsFigure(takeCount)
    }

    /// As needed, the dose set for it; otherwise the first scheduled amount.
    private var extraAmount: Double {
        medicine.schedule.frequency == .asNeeded ? medicine.asNeededAmount : (medicine.schedule.times.first?.amount ?? 1)
    }

    private func takeExtra() {
        Cabinet.takeExtra(medicine, amount: extraAmount, at: clock.now, calendar: calendar, in: modelContext)
        try? modelContext.save()
        clock.refresh()
        takeCount += 1
    }

    private func refill() {
        isRefilling = true
    }

    private func edit() {
        isEditing = true
    }
}

#Preview("Light") {
    MedicineViewPreview()
}

#Preview("Dark") {
    MedicineViewPreview()
        .preferredColorScheme(.dark)
}

private struct MedicineViewPreview: View {
    @Query private var medicines: [Medicine]

    var body: some View {
        NavigationStack {
            if let medicine = medicines.first(where: { $0.stock != nil }) {
                MedicineView(medicine: medicine)
            }
        }
        .modelContainer(.preview)
        .environment(Clock())
        .environment(\.sbuAccent, .meds)
    }
}
