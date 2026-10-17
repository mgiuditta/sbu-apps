import Charts
import SbuKit
import SwiftUI

/// The weighted average after each graded exam, oldest first, in ink on paper. Touch the chart to read one.
struct AverageChart: View {
    let points: [AveragePoint]
    /// The exam names by id, for the callout.
    let names: [ExamRecord.ID: String]

    @State private var selectedIndex: Int?
    @ScaledMetric(relativeTo: .body) private var height = 180

    var body: some View {
        if points.count < 2 {
            ChartPlaceholder(text: "Il grafico compare dal secondo voto.")
        } else {
            Chart {
                ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                    LineMark(x: .value("Esame", index + 1), y: .value("Media", point.average))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.monotone)
                    PointMark(x: .value("Esame", index + 1), y: .value("Media", point.average))
                        .symbolSize(40)
                        .accessibilityLabel(names[point.id] ?? "")
                        .accessibilityValue(point.average.formatted(LibrettoFormat.average))
                }
                .foregroundStyle(SbuTheme.ink)
                if let selected {
                    RuleMark(x: .value("Esame", selected.index + 1))
                        .foregroundStyle(SbuTheme.line)
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            ChartCallout(value: selected.point.average.formatted(LibrettoFormat.average), detail: names[selected.point.id] ?? "")
                        }
                }
            }
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXScale(domain: 1...points.count)
            // The exams are steps, not quantities: no axis numbers under them.
            .chartXAxis(.hidden)
            .chartXSelection(value: $selectedIndex)
            // Axis labels stop growing at the largest standard size; the values stay readable in VoiceOver.
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .frame(height: height)
            .padding(.vertical, SbuTheme.space2)
            .accessibilityIdentifier("averageChart")
        }
    }

    private var selected: (index: Int, point: AveragePoint)? {
        guard let selectedIndex else { return nil }
        let index = min(max(selectedIndex - 1, 0), points.count - 1)
        return (index, points[index])
    }
}

#Preview("Light") {
    VStack {
        AverageChart(points: Transcript([
            ExamRecord(credits: 12, result: .graded(.mark(24)), date: .now.addingTimeInterval(-86_400 * 90)),
            ExamRecord(credits: 6, result: .graded(.mark(28)), date: .now.addingTimeInterval(-86_400 * 60)),
            ExamRecord(credits: 9, result: .graded(.cumLaude), date: .now.addingTimeInterval(-86_400 * 30)),
            ExamRecord(credits: 6, result: .graded(.mark(26)), date: .now),
        ], rules: .standard).trend, names: [:])
    }
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper(grid: false)
}

#Preview("Dark") {
    AverageChart(points: [], names: [:])
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: false)
        .preferredColorScheme(.dark)
}
