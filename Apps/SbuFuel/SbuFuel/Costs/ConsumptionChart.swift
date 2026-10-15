import Charts
import SbuKit
import SwiftUI

/// The consumption of each full-to-full segment over time. Touch the chart to read one.
struct ConsumptionChart: View {
    let segments: [ConsumptionSegment]
    let unit: ConsumptionUnit

    @State private var selectedDate: Date?
    @ScaledMetric(relativeTo: .body) private var height = 180

    var body: some View {
        if segments.count < 2 {
            ChartPlaceholder(text: "Il grafico compare con almeno due tratti da pieno a pieno nel periodo.")
        } else {
            Chart {
                ForEach(segments, id: \.endID) { segment in
                    LineMark(x: .value("Data", segment.endDate), y: .value(unit.symbol, value(segment)))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.monotone)
                    PointMark(x: .value("Data", segment.endDate), y: .value(unit.symbol, value(segment)))
                        .symbolSize(40)
                        .accessibilityLabel(segment.endDate.formatted(date: .abbreviated, time: .omitted))
                        .accessibilityValue(text(segment))
                }
                .foregroundStyle(.tint)
                if let selected {
                    RuleMark(x: .value("Data", selected.endDate))
                        .foregroundStyle(SbuTheme.line)
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            ChartCallout(value: text(selected), date: selected.endDate.formatted(date: .abbreviated, time: .omitted))
                        }
                }
            }
            .chartYScale(domain: .automatic(includesZero: false))
            .chartYAxisLabel(unit.symbol)
            .chartXSelection(value: $selectedDate)
            .frame(height: height)
            .padding(.vertical, SbuTheme.space2)
            .listRowBackground(SbuTheme.surfaceRaised)
        }
    }

    /// The segment nearest to the touched date.
    private var selected: ConsumptionSegment? {
        guard let selectedDate else { return nil }
        return segments.min { abs($0.endDate.timeIntervalSince(selectedDate)) < abs($1.endDate.timeIntervalSince(selectedDate)) }
    }

    private func value(_ segment: ConsumptionSegment) -> Double {
        unit.value(fromKmPerLitre: segment.kmPerLitre)
    }

    private func text(_ segment: ConsumptionSegment) -> String {
        unit.formatted(kmPerLitre: segment.kmPerLitre) + "\u{00A0}" + unit.symbol
    }
}

#Preview("Light") {
    List {
        ConsumptionChart(segments: ConsumptionCalculator([
            FillRecord(date: .now.addingTimeInterval(-86_400 * 40), odometerKm: 1_000, litres: 30),
            FillRecord(date: .now.addingTimeInterval(-86_400 * 20), odometerKm: 1_600, litres: 37),
            FillRecord(date: .now, odometerKm: 2_150, litres: 32),
        ]).segments, unit: .litresPer100Km)
    }
    .tint(SbuTheme.accentFuel)
}

#Preview("Dark") {
    List {
        ConsumptionChart(segments: [], unit: .mpgUS)
    }
    .tint(SbuTheme.accentFuel)
    .preferredColorScheme(.dark)
}
