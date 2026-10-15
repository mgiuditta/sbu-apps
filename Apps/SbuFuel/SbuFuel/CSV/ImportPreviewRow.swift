import SbuKit
import SwiftUI

/// One row of the import preview, read with the chosen columns and units.
struct ImportPreviewRow: View {
    let entry: ImportedEntry
    let distanceUnit: DistanceUnit
    let volumeUnit: VolumeUnit

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
            Text(detail)
                .font(SbuTheme.subheadline)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .accessibilityElement(children: .combine)
    }

    private var title: String {
        switch entry {
        case let .fuel(record, _, _): record.date.formatted(.dateTime.day().month(.abbreviated).year())
        case let .service(title, date, _, _, _): "\(title) · \(date.formatted(.dateTime.day().month(.abbreviated).year()))"
        }
    }

    private var detail: String {
        switch entry {
        case let .fuel(record, _, _):
            let kind = record.isFull ? String(localized: "pieno") : String(localized: "parziale")
            return [distanceUnit.formatted(km: record.odometerKm), volumeUnit.formatted(litres: record.litres), Money.text(record.totalPrice), kind]
                .joined(separator: " · ")
        case let .service(_, _, odometerKm, cost, _):
            return ([odometerKm.map { distanceUnit.formatted(km: $0) }, Money.text(cost)].compactMap { $0 }).joined(separator: " · ")
        }
    }
}

#Preview("Light") {
    List {
        ImportPreviewRow(entry: .fuel(FillRecord(date: .now, odometerKm: 45_210, litres: 38.2, totalPrice: 68.4), station: "", note: ""),
                         distanceUnit: .kilometres, volumeUnit: .litres)
    }
}

#Preview("Dark") {
    List {
        ImportPreviewRow(entry: .service(title: "Cambio olio", date: .now, odometerKm: 45_250, cost: 89, note: ""),
                         distanceUnit: .kilometres, volumeUnit: .litres)
    }
    .preferredColorScheme(.dark)
}
