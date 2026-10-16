import SbuKit
import SwiftData
import SwiftUI

/// The whole history of a medicine, month by month: Medisafe keeps 30 days, this keeps everything.
struct MedicineHistoryView: View {
    let medicine: Medicine

    @Environment(\.calendar) private var calendar

    var body: some View {
        List {
            ForEach(MedicineHistory.months(of: medicine.snapshot), id: \.month) { month in
                Section {
                    ForEach(month.entries, id: \.self) { record in
                        HistoryRow(record: record, form: medicine.form)
                    }
                } header: {
                    Text(month.month.start(in: calendar), format: .dateTime.month(.wide).year())
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Storico")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    MedicineHistoryViewPreview()
}

#Preview("Dark") {
    MedicineHistoryViewPreview()
        .preferredColorScheme(.dark)
}

private struct MedicineHistoryViewPreview: View {
    @Query private var medicines: [Medicine]

    var body: some View {
        NavigationStack {
            if let medicine = medicines.first {
                MedicineHistoryView(medicine: medicine)
            }
        }
        .modelContainer(.preview)
        .tint(SbuTheme.accentMeds)
    }
}
