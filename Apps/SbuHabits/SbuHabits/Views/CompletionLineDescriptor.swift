import Accessibility
import SwiftUI

/// The completion line as an audio graph: one point per stretch of days, named by its days.
struct CompletionLineDescriptor: AXChartDescriptorRepresentable {
    let points: [CompletionPoint]
    let calendar: Calendar

    func makeChartDescriptor() -> AXChartDescriptor {
        let names = points.map(name(of:))
        let percent = FloatingPointFormatStyle<Double>.Percent.percent.precision(.fractionLength(0...1))
        let days = AXCategoricalDataAxisDescriptor(title: String(localized: "Giorni"), categoryOrder: names)
        let rate = AXNumericDataAxisDescriptor(title: String(localized: "Completamento"), range: 0...1, gridlinePositions: []) { value in
            value.formatted(percent)
        }
        let series = AXDataSeriesDescriptor(
            name: String(localized: "Completamento"),
            isContinuous: true,
            dataPoints: zip(names, points).map { AXDataPoint(x: $0, y: $1.rate) }
        )
        return AXChartDescriptor(title: String(localized: "Completamento nel tempo"), summary: nil, xAxis: days, yAxis: rate, additionalAxes: [], series: [series])
    }

    /// The days of a point: one day, or the first and the last.
    private func name(of point: CompletionPoint) -> String {
        let first = point.firstDay.noon(in: calendar)
        guard point.firstDay != point.lastDay else {
            return first.formatted(.dateTime.day().month(.wide))
        }
        return (first..<point.lastDay.noon(in: calendar)).formatted(.interval.day().month(.wide))
    }
}
