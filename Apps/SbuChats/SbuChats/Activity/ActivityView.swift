import Charts
import SbuKit
import SwiftUI

/// When the chat talks: messages by hour, weekday, month and year, you apart from the others.
struct ActivityView: View {
    let statistics: ChatStatistics
    /// The sender who is you, if known: your bars are in the accent.
    let owner: String?
    /// The other person in a two-person chat; "Gli altri" otherwise.
    let otherName: String?

    @State private var axis: ActivityAxis = .hour
    @State private var selectedLabel: String?
    @ScaledMetric(relativeTo: .body) private var chartHeight: CGFloat = 240

    /// The chart grows with the text, but past this it pushed the bars off the screen.
    private static let maximumChartHeight: CGFloat = 360

    var body: some View {
        let data = ActivityChartData(axis: axis, points: statistics.activity[axis] ?? [])
        List {
            Section {
                Picker("Raggruppa per", selection: $axis) {
                    ForEach(ActivityAxis.allCases) { axis in
                        Text(axis.title).tag(axis)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            Section {
                ActivitySummary(data: data, axis: axis, selectedLabel: selectedLabel, seriesName: seriesName)
                ActivityChart(data: data, axis: axis, selectedLabel: $selectedLabel, seriesName: seriesName, height: min(chartHeight, Self.maximumChartHeight))
            } footer: {
                if owner != nil {
                    Text("In inchiostro i tuoi messaggi, in grigio quelli degli altri. Tocca o trascina sul grafico per leggere una barra.")
                } else {
                    Text("Tocca o trascina sul grafico per leggere una barra. Scegli chi sei per separare i tuoi messaggi.")
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .navigationTitle(Text("Attività"))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: axis) {
            selectedLabel = nil
        }
    }

    private func seriesName(_ series: ActivitySeries) -> String {
        switch series {
        case .you: String(localized: "Tu")
        case .others: otherName ?? String(localized: "Gli altri")
        case .everyone: String(localized: "Messaggi")
        }
    }
}

#Preview("Light") {
    NavigationStack { ActivityView(statistics: .empty, owner: "Giulia", otherName: "Marco") }
}

#Preview("Dark") {
    NavigationStack { ActivityView(statistics: .empty, owner: "Giulia", otherName: "Marco") }
        .preferredColorScheme(.dark)
}
