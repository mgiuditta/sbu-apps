import SbuKit
import SwiftUI

/// The line above the chart: the bar you touch, or where the chat is busiest.
struct ActivitySummary: View {
    let data: ActivityChartData
    let axis: ActivityAxis
    let selectedLabel: String?
    let seriesName: (ActivitySeries) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            if let slot = data.slots.first(where: { $0.label == selectedLabel }) {
                Text(verbatim: slotName(slot).capitalizedFirst)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                Text("\(data.total(in: slot)) messaggi")
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
                if let breakdown = breakdown(slot) {
                    Text(verbatim: breakdown)
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            } else if let peak = data.peak {
                Text("Il momento più attivo: \(slotName(peak))")
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                Text("\(data.total(in: peak)) messaggi")
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            } else {
                Text("Nessun messaggio in questo periodo")
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    /// "alle 21", "lun", "mar 24", "2024".
    private func slotName(_ slot: ActivityChartData.Slot) -> String {
        axis == .hour ? String(localized: "alle \(slot.label)") : slot.label
    }

    /// "Tu 120 · Marco 220", when the chart has more than one series.
    private func breakdown(_ slot: ActivityChartData.Slot) -> String? {
        let series = Array(Set(data.bars.map(\.series))).sorted { $0.rawValue > $1.rawValue }
        guard series.count > 1 else { return nil }
        return series.map { "\(seriesName($0)) \(data.count(in: slot, series: $0).formatted())" }.joined(separator: " · ")
    }
}
