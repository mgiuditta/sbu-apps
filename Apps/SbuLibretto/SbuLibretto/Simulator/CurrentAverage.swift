import SbuKit
import SwiftUI

/// The figure of the simulator: the weighted average today, closed by the full stop, on how many credits.
struct CurrentAverage: View {
    let transcript: Transcript

    var body: some View {
        if let average = transcript.weightedAverage {
            let value = average.formatted(LibrettoFormat.average)
            SbuFigure(
                value: value,
                fullStop: .set,
                context: Text(context),
                accessibilityLabel: Text("La tua media attuale") + Text(verbatim: ", \(value), ") + Text(context)
            )
            .accessibilityIdentifier("currentAverage")
        } else {
            // No figure before the first grade: a 0,00 would read as a real average.
            Text("Nessun voto ancora: la media sarà il voto del prossimo esame.")
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.inkMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("currentAverage")
        }
    }

    private var context: LocalizedStringKey {
        let credits = transcript.countedExams.reduce(0) { $0 + $1.credits }
        return "Su \(credits.formatted(LibrettoFormat.credits)) CFU con voto"
    }
}

#Preview("Light") {
    CurrentAverage(transcript: Transcript([ExamRecord(credits: 91, result: .graded(.mark(28)), date: nil)], rules: .standard))
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .environment(\.sbuAccent, .libretto)
}

#Preview("Dark") {
    CurrentAverage(transcript: Transcript([], rules: .standard))
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .environment(\.sbuAccent, .libretto)
        .preferredColorScheme(.dark)
}
