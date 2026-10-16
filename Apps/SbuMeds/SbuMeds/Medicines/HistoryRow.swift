import SbuKit
import SwiftUI

/// One entry of a medicine's history: when it was due, and taken at what time, skipped or missed.
struct HistoryRow: View {
    let record: DoseRecordSnapshot
    let form: MedicineForm

    @Environment(\.calendar) private var calendar

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            Text(record.key.date(in: calendar), format: .dateTime.weekday(.abbreviated).day().month(.abbreviated).year().hour().minute())
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
            HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space1) {
                Image(systemName: symbol)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .accessibilityHidden(true)
                text
            }
            .font(SbuTheme.footnote)
            .foregroundStyle(color)
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

    private var symbol: String {
        switch record.mark {
        case .taken: "checkmark.circle.fill"
        case .skipped: "minus.circle"
        case .missed: "exclamationmark.circle"
        case .moved: "clock.arrow.circlepath"
        }
    }

    private var color: Color {
        switch record.mark {
        case .taken: SbuTheme.success
        case .missed: SbuTheme.danger
        case .skipped, .moved: SbuTheme.inkMuted
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
        .background(SbuTheme.surface)
    }
}
