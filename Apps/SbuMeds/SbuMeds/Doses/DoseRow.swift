import SbuKit
import SwiftUI

/// A dose in a list: the medicine's form, its name, how much, and where it stands.
struct DoseRow: View {
    let item: DoseItem

    var body: some View {
        HStack(spacing: SbuTheme.space3) {
            Image(systemName: item.medicine.form.systemImage)
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
                .frame(width: SbuTheme.space6)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                Text(item.medicine.name)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                detail
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
                DoseStateLabel(item: item)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, SbuTheme.space1)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    private var detail: Text {
        let text = item.medicine.detail(amount: item.amount)
        return item.isExtra ? Text("\(text) · dose extra") : Text(verbatim: text)
    }
}

#Preview("Light") {
    DoseRowsPreview()
}

#Preview("Dark") {
    DoseRowsPreview()
        .preferredColorScheme(.dark)
}

/// Doses in every state, for the previews of the row and its label.
struct DoseRowsPreview: View {
    var body: some View {
        let calendar = Calendar.current
        let now = Date.now
        let today = Day(now, calendar: calendar)
        let id = UUID()
        let records = [
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: today, minutes: 0), mark: .taken, markedAt: now),
            DoseRecordSnapshot(key: DoseKey(medicineID: id, day: today, minutes: 60), mark: .skipped),
        ]
        let medicine = MedicineSnapshot(
            id: id, name: "Ramipril", strength: "5 mg",
            schedule: Schedule(times: [DoseTime(hour: 0), DoseTime(hour: 1), DoseTime(hour: 2), DoseTime(hour: 23, minute: 59)], start: today),
            records: records
        )
        return List {
            ForEach(DayPlan([medicine], day: today, now: now, calendar: calendar).items) { item in
                DoseRow(item: item)
                    .listRowBackground(SbuTheme.surfaceRaised)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
    }
}
