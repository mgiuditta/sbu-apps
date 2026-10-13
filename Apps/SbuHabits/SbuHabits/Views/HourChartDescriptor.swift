import Accessibility
import SwiftUI

/// The hour curve as an audio graph: completions at each hour of the day.
struct HourChartDescriptor: AXChartDescriptorRepresentable {
    /// 24 counts, index 0 for 00:00–00:59.
    let hours: [Int]
    let calendar: Calendar

    func makeChartDescriptor() -> AXChartDescriptor {
        let names = hours.indices.map { Self.time(at: $0, in: calendar).formatted(.dateTime.hour().minute()) }
        let hourAxis = AXCategoricalDataAxisDescriptor(title: String(localized: "Ora"), categoryOrder: names)
        let countAxis = AXNumericDataAxisDescriptor(title: String(localized: "Completamenti"), range: 0...Double(max(hours.max() ?? 0, 1)), gridlinePositions: []) { value in
            Int(value).formatted()
        }
        let series = AXDataSeriesDescriptor(
            name: String(localized: "Completamenti"),
            isContinuous: true,
            dataPoints: zip(names, hours).map { AXDataPoint(x: $0, y: Double($1)) }
        )
        return AXChartDescriptor(title: String(localized: "Completamenti per ora"), summary: nil, xAxis: hourAxis, yAxis: countAxis, additionalAxes: [], series: [series])
    }

    /// Today at `hour`:00, only to format the hour for the user's locale.
    static func time(at hour: Int, in calendar: Calendar) -> Date {
        calendar.date(bySettingHour: hour, minute: 0, second: 0, of: .now) ?? .now
    }
}
