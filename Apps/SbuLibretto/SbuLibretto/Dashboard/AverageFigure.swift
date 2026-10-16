import SbuKit
import SwiftUI

/// The one figure of the app: the weighted average, closed by the full stop, and how the last
/// exam moved it. Before the first grade, what to do instead.
struct AverageFigure: View {
    let transcript: Transcript

    var body: some View {
        if let average = transcript.weightedAverage {
            SbuToolField(
                "Media ponderata",
                value: average,
                format: LibrettoFormat.average,
                context: context,
                contextSystemImage: symbol,
                contextTone: tone
            ) {
                EmptyView()
            } pills: {
                EmptyView()
            }
            .accessibilityIdentifier("figure")
        } else {
            SbuToolField("Media ponderata", context: "Registra il primo voto per vedere la media.") {
                EmptyView()
            } pills: {
                EmptyView()
            }
            .accessibilityIdentifier("figure")
        }
    }

    private var context: LocalizedStringKey {
        guard let change = transcript.lastChange else {
            return transcript.gradedExams.count == 1 ? "Dal primo voto" : "Pesata sui CFU"
        }
        if abs(change) < 0.005 { return "Invariata dall'ultimo esame" }
        return "\(change.formatted(LibrettoFormat.change)) dall'ultimo esame"
    }

    /// A word and a symbol with the status color, never the color alone.
    private var symbol: String? {
        guard let change = transcript.lastChange, abs(change) >= 0.005 else { return nil }
        return change > 0 ? "arrow.up.right" : "arrow.down.right"
    }

    private var tone: SbuStatusTone {
        guard let change = transcript.lastChange, abs(change) >= 0.005 else { return .neutral }
        return change > 0 ? .success : .danger
    }
}

#Preview("Light") {
    AverageFigure(transcript: Transcript([
        ExamRecord(credits: 12, result: .graded(.mark(26)), date: .now.addingTimeInterval(-86_400)),
        ExamRecord(credits: 6, result: .graded(.cumLaude), date: .now),
    ], rules: .standard))
    .background(SbuTheme.surface)
    .tint(SbuTheme.accentLibretto)
}

#Preview("Dark") {
    AverageFigure(transcript: Transcript([ExamRecord(credits: 9, result: .pending, date: nil)], rules: .standard))
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentLibretto)
        .preferredColorScheme(.dark)
}
