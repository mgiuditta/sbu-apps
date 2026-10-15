import SbuKit
import SwiftUI

/// The last, best and worst full-to-full segments under the average.
struct ConsumptionSection: View {
    let consumption: ConsumptionCalculator
    let unit: ConsumptionUnit

    var body: some View {
        Section("Consumo") {
            if let last = consumption.last {
                ValueRow(title: "Ultimo pieno", value: text(last), spokenValue: unit.spoken(kmPerLitre: last.kmPerLitre))
            }
            if consumption.segments.count > 1, let best = consumption.best, let worst = consumption.worst {
                ValueRow(title: "Il migliore", value: text(best), spokenValue: unit.spoken(kmPerLitre: best.kmPerLitre))
                ValueRow(title: "Il peggiore", value: text(worst), spokenValue: unit.spoken(kmPerLitre: worst.kmPerLitre))
            }
        }
    }

    private func text(_ segment: ConsumptionSegment) -> String {
        unit.formatted(kmPerLitre: segment.kmPerLitre) + "\u{00A0}" + unit.symbol
    }
}

#Preview("Light") {
    List {
        ConsumptionSection(consumption: ConsumptionCalculator([
            FillRecord(date: .now, odometerKm: 1_000, litres: 30),
            FillRecord(date: .now, odometerKm: 1_600, litres: 37),
            FillRecord(date: .now, odometerKm: 2_100, litres: 33),
        ]), unit: .litresPer100Km)
    }
}

#Preview("Dark") {
    List {
        ConsumptionSection(consumption: ConsumptionCalculator([
            FillRecord(date: .now, odometerKm: 1_000, litres: 30),
            FillRecord(date: .now, odometerKm: 1_600, litres: 37),
        ]), unit: .mpgUS)
    }
    .preferredColorScheme(.dark)
}
