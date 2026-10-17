import SbuKit
import SwiftUI

/// One entry of a medicine's history: when it was due, then the row marker (filled when taken) and
/// taken at what time, skipped or missed.
struct HistoryRow: View {
    let record: DoseRecordSnapshot
    let form: MedicineForm

    @Environment(\.calendar) private var calendar

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            Text(record.key.date(in: calendar), format: .dateTime.weekday(.abbreviated).day().month(.abbreviated).year().hour().minute())
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
            HStack(spacing: SbuTheme.space2) {
                SbuRowMark(filled: record.mark == .taken)
                text
            }
            .font(SbuTheme.footnote)
            .foregroundStyle(record.mark == .taken ? SbuTheme.ink : SbuTheme.inkMuted)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("historyEntry")
    }

    private var text: Text {
        let amount = form.amountText(record.amount)
        switch record.mark {
        case .taken:
            let time = Text(record.markedAt ?? record.key.date(in: calendar), format: .dateTime.hour().minute())
            return record.isExtra ? Text("Dose extra, \(amount)") : Text("Presa alle \(time), \(amount)")
        case .skipped: return Text("Saltata")
        case .missed: return Text("Non segnata")
        case .moved: return Text("Spostata")
        }
    }
}

#Preview("Light") {
    HistoryRowPreview()
}

#Preview("Dark") {
    HistoryRowPreview()
        .preferredColorScheme(.dark)
}

private struct HistoryRowPreview: View {
    var body: some View {
        let key = DoseKey(medicineID: UUID(), day: Day(.now, calendar: .current), minutes: 8 * 60)
        List {
            ForEach([DoseMark.taken, .skipped, .missed], id: \.self) { mark in
                HistoryRow(record: DoseRecordSnapshot(key: key, mark: mark, markedAt: .now), form: .tablet)
                    .listRowBackground(SbuTheme.surfaceRaised)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
    }
}
