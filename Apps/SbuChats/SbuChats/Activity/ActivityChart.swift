import Charts
import SbuKit
import SwiftUI

/// The bars, stacked by series: yours in the accent, the others' in grey.
struct ActivityChart: View {
    let data: ActivityChartData
    let axis: ActivityAxis
    @Binding var selectedLabel: String?
    let seriesName: (ActivitySeries) -> String
    let height: CGFloat

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Chart(data.bars) { bar in
            BarMark(
                x: .value("Quando", bar.slot.label),
                y: .value("Messaggi", bar.count)
            )
            .foregroundStyle(by: .value("Chi", seriesName(bar.series)))
            .opacity(selectedLabel == nil || selectedLabel == bar.slot.label ? 1 : 0.4)
        }
        .chartForegroundStyleScale(domain: seriesDomain, range: seriesColors)
        .chartXAxis {
            AxisMarks(values: axisValues) { _ in
                AxisValueLabel()
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                    .foregroundStyle(SbuTheme.line)
                AxisValueLabel()
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        .chartLegend(seriesDomain.count > 1 ? .visible : .hidden)
        .chartXSelection(value: $selectedLabel)
        .frame(height: height)
        .padding(.vertical, SbuTheme.space2)
        // One element for VoiceOver: every slot with its messages, in order. Bars a few points wide
        // are no target to find by touch, and the summary above already reads the busiest one.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(axis.chartTitle))
        .accessibilityValue(Text(verbatim: spokenValues))
    }

    /// "21: 340, 22: 310…", only the slots with messages.
    private var spokenValues: String {
        data.slots.compactMap { slot in
            let total = data.total(in: slot)
            return total > 0 ? "\(slot.label): \(total.formatted())" : nil
        }
        .joined(separator: ", ")
    }

    private var series: [ActivitySeries] {
        Array(Set(data.bars.map(\.series))).sorted { $0.rawValue > $1.rawValue }
    }

    private var seriesDomain: [String] {
        series.map(seriesName)
    }

    /// You and everyone in the accent, the others in grey.
    private var seriesColors: [Color] {
        series.map { $0 == .others ? SbuTheme.inkMuted : SbuTheme.accentChats }
    }

    /// Every hour would crowd the axis: one label in three (six at the accessibility sizes); months
    /// about four labels (one). Never a label on the first bar, nor a month on the last, where it
    /// would run past the chart's edge and be cut.
    private var axisValues: [String] {
        let labels = data.slots.map(\.label)
        let isLarge = dynamicTypeSize.isAccessibilitySize
        switch axis {
        case .hour:
            let step = isLarge ? 6 : 3
            return labels.enumerated().filter { $0.offset > 0 && $0.offset.isMultiple(of: step) }.map(\.element)
        case .weekday, .year:
            return labels
        case .month:
            // At the accessibility sizes a month's name is wider than a third of the chart: one, mid-way.
            if isLarge { return labels.isEmpty ? [] : [labels[labels.count / 2]] }
            let count = 4
            guard labels.count > count else { return labels }
            let stride = max(1, (labels.count - 2) / count)
            return labels.enumerated()
                .filter { $0.offset > 0 && $0.offset < labels.count - 1 && ($0.offset - 1).isMultiple(of: stride) }
                .map(\.element)
        }
    }
}
