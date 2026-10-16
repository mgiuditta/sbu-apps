import SbuKit
import SwiftData
import SwiftUI

/// The latest entries of the history, then the whole of it, with no limit of days.
struct MedicineHistorySection: View {
    static let shown = 10

    let medicine: Medicine

    var body: some View {
        let history = MedicineHistory.entries(of: medicine.snapshot)
        Section {
            ForEach(history.prefix(Self.shown), id: \.self) { record in
                HistoryRow(record: record, form: medicine.form)
            }
            if history.count > Self.shown {
                NavigationLink {
                    MedicineHistoryView(medicine: medicine)
                } label: {
                    Text("Tutto lo storico")
                }
                .accessibilityIdentifier("fullHistory")
            }
        } header: {
            Text("Storico")
        } footer: {
            if history.isEmpty {
                Text("Qui trovi ogni dose presa, saltata o non segnata, per sempre.")
            }
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }
}

#Preview("Light") {
    MedicineHistorySectionPreview()
}

#Preview("Dark") {
    MedicineHistorySectionPreview()
        .preferredColorScheme(.dark)
}

private struct MedicineHistorySectionPreview: View {
    @Query private var medicines: [Medicine]

    var body: some View {
        NavigationStack {
            List {
                if let medicine = medicines.first {
                    MedicineHistorySection(medicine: medicine)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.surface)
        }
        .modelContainer(.preview)
        .tint(SbuTheme.accentMeds)
    }
}
