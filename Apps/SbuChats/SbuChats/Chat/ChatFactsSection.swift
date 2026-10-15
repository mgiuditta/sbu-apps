import SbuKit
import SwiftUI

/// The chat as a whole: days, streak, conversations, pace; and how they are counted.
struct ChatFactsSection: View {
    let statistics: ChatStatistics

    var body: some View {
        Section {
            StatRow(title: "Giorni con messaggi", value: Text(statistics.activeDays, format: .number))
            StatRow(title: "Giorni di fila, record", value: Text("\(statistics.longestStreak) giorni"))
            StatRow(title: "Conversazioni", value: Text(statistics.conversations, format: .number))
            StatRow(title: "Messaggi al giorno", value: Text(perDay, format: .number.precision(.fractionLength(0 ... 1))))
        } header: {
            Text("La chat")
        } footer: {
            Text("Una conversazione ricomincia dopo 6 ore di silenzio. Le risposte arrivate dopo più di 24 ore non entrano nei tempi di risposta. Messaggi al giorno conta solo i giorni con messaggi.")
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }

    private var perDay: Double {
        statistics.activeDays == 0 ? 0 : Double(statistics.totalMessages) / Double(statistics.activeDays)
    }
}

#Preview("Light") {
    List { ChatFactsSection(statistics: .empty) }
}

#Preview("Dark") {
    List { ChatFactsSection(statistics: .empty) }
        .preferredColorScheme(.dark)
}
