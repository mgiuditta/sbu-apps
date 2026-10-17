import Charts
import SbuKit
import SwiftUI

/// The price you paid per litre or gallon at each paid fuel-up.
struct PriceChart: View {
    let fills: [FillRecord]
    let volumeUnit: VolumeUnit

    @State private var selectedDate: Date?
    @ScaledMetric(relativeTo: .body) private var height = 180

    private var paid: [FillRecord] {
        fills.filter { $0.totalPrice > 0 && $0.litres > 0 }.sorted { $0.date < $1.date }
    }

    var body: some View {
        let points = paid
        if points.count < 2 {
            ChartPlaceholder(text: "Il grafico compare con almeno due rifornimenti pagati nel periodo.")
        } else {
            Chart {
                ForEach(points) { fill in
                    LineMark(x: .value("Data", fill.date), y: .value("Prezzo", price(fill)))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .accessibilityLabel(fill.date.formatted(date: .abbreviated, time: .omitted))
                        .accessibilityValue(text(fill))
                }
                .foregroundStyle(SbuTheme.ink)
                if let selected = nearest(in: points) {
                    RuleMark(x: .value("Data", selected.date))
                        .foregroundStyle(SbuTheme.line)
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            ChartCallout(value: text(selected), date: selected.date.formatted(date: .abbreviated, time: .omitted))
                        }
                    PointMark(x: .value("Data", selected.date), y: .value("Prezzo", price(selected)))
                        .foregroundStyle(SbuTheme.ink)
                        .symbolSize(60)
                }
            }
            .chartYScale(domain: domain(points))
            .chartXSelection(value: $selectedDate)
            // Axis labels stop growing at the largest standard size: beyond it the months turned into ellipses.
            // The values stay readable under your finger and in VoiceOver at every size.
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .frame(height: height)
            .padding(.vertical, SbuTheme.space2)
            .listRowBackground(SbuTheme.surfaceRaised)
        }
    }

    /// At least 2% of the price above and below: a tenth of a cent of rounding never looks like a spike.
    private func domain(_ points: [FillRecord]) -> ClosedRange<Double> {
        let prices = points.map(price)
        guard let low = prices.min(), let high = prices.max() else { return 0...1 }
        let pad = max((high - low) * 0.2, (high + low) / 2 * 0.02)
        return (low - pad)...(high + pad)
    }

    private func nearest(in points: [FillRecord]) -> FillRecord? {
        guard let selectedDate else { return nil }
        return points.min { abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate)) }
    }

    private func perLitre(_ fill: FillRecord) -> Decimal {
        fill.totalPrice / Decimal(fill.litres)
    }

    private func price(_ fill: FillRecord) -> Double {
        NSDecimalNumber(decimal: perLitre(fill) * Decimal(volumeUnit.litres(from: 1))).doubleValue
    }

    private func text(_ fill: FillRecord) -> String {
        Money.perVolume(perLitre(fill), unit: volumeUnit)
    }
}

#Preview("Light") {
    List {
        PriceChart(fills: [
            FillRecord(date: .now.addingTimeInterval(-86_400 * 40), odometerKm: 1_000, litres: 30, totalPrice: 54),
            FillRecord(date: .now.addingTimeInterval(-86_400 * 20), odometerKm: 1_600, litres: 37, totalPrice: 68),
            FillRecord(date: .now, odometerKm: 2_150, litres: 32, totalPrice: 57),
        ], volumeUnit: .litres)
    }
}

#Preview("Dark") {
    List {
        PriceChart(fills: [], volumeUnit: .usGallons)
    }
    .preferredColorScheme(.dark)
}
