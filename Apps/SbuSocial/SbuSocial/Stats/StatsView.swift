import SbuKit
import SwiftUI

/// The Statistiche tab, as in SocialLite: minutes a day over the last seven days, the week in
/// bars, and today's minutes on each Platform.
struct StatsView: View {
    @Environment(UsageLog.self) private var usage

    private var today: [PlatformMinutes] {
        Platform.allCases
            .map { PlatformMinutes(platform: $0, minutes: usage.minutes(on: .now, platform: $0)) }
            .filter { $0.minutes > 0 }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                SbuScreenTitle("Statistiche", cartiglio: Cartiglio.today)
                if usage.lastSevenDays.allSatisfy({ usage.minutes(on: $0) == 0 }) {
                    SbuEmpty(sentence: "Qui vedi i tuoi minuti degli ultimi 7 giorni.") {
                        EmptyView()
                    }
                } else {
                    SbuFigure(value: usage.averageMinutes.formatted(), fullStop: .waiting,
                              context: Text("minuti al giorno, ultimi 7 giorni"))
                    WeekChart(usage: usage)
                    if !today.isEmpty {
                        Text("Oggi")
                            .font(SbuTheme.headline)
                            .accessibilityAddTraits(.isHeader)
                        SbuListCard(today) { row in
                            LabeledContent {
                                Text(Duration.seconds(row.minutes * 60), format: .units(allowed: [.hours, .minutes], width: .abbreviated))
                                    .monospacedDigit()
                            } label: {
                                Text(verbatim: row.platform.name)
                            }
                        }
                    }
                }
            }
            .padding(SbuTheme.space4)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .sbuPaper(grid: true)
    }
}

#Preview("Light") {
    NavigationStack {
        StatsView()
    }
    .environment(UsageLog(defaults: UserDefaults(suiteName: "preview")!))
}

#Preview("Dark") {
    NavigationStack {
        StatsView()
    }
    .environment(UsageLog(defaults: UserDefaults(suiteName: "preview")!))
    .preferredColorScheme(.dark)
}
