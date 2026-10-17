import SbuKit
import SwiftUI

/// The one figure of the app: the weighted average, closed by the full stop, and how the last
/// exam moved it, said with its sign. Before the first grade, a waiting "0" and what to do instead.
struct AverageFigure: View {
    let transcript: Transcript

    var body: some View {
        if let average = transcript.weightedAverage {
            let value = average.formatted(LibrettoFormat.average)
            SbuFigure(
                value: value,
                fullStop: .set,
                context: Text(context),
                accessibilityLabel: Text("Media ponderata") + Text(verbatim: ", \(value), ") + Text(context)
            )
            .accessibilityIdentifier("figure")
        } else {
            // No figure before the first grade: a 0,00 would read as a real average.
            SbuEmpty(sentence: "Registra il primo voto per vedere la media.")
        }
    }

    /// The change in words with its sign, never in a color alone.
    private var context: LocalizedStringKey {
        guard let change = transcript.lastChange else {
            return transcript.gradedExams.count == 1 ? "Dal primo voto" : "Pesata sui CFU"
        }
        if abs(change) < 0.005 { return "Invariata dall'ultimo esame" }
        return "\(change.formatted(LibrettoFormat.change)) dall'ultimo esame"
    }
}

#Preview("Light") {
    AverageFigure(transcript: Transcript([
        ExamRecord(credits: 12, result: .graded(.mark(26)), date: .now.addingTimeInterval(-86_400)),
        ExamRecord(credits: 6, result: .graded(.cumLaude), date: .now),
    ], rules: .standard))
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper(grid: true)
    .environment(\.sbuAccent, .libretto)
}

#Preview("Dark") {
    AverageFigure(transcript: Transcript([ExamRecord(credits: 9, result: .pending, date: nil)], rules: .standard))
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: true)
        .environment(\.sbuAccent, .libretto)
        .preferredColorScheme(.dark)
}
