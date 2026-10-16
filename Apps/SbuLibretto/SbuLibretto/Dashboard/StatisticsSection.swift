import SbuKit
import SwiftUI

/// The statistics under the figure: how the average went, then the secondary figures.
struct StatisticsSection: View {
    let transcript: Transcript
    let names: [ExamRecord.ID: String]

    var body: some View {
        Section("Andamento media") {
            AverageChart(points: transcript.trend, names: names)
        }
        Section("Statistiche") {
            if let arithmetic = transcript.arithmeticAverage {
                ValueRow(title: "Media aritmetica", value: arithmetic.formatted(LibrettoFormat.average))
            }
            if let base = transcript.base {
                ValueRow(title: "Base di laurea", value: base.text)
            }
            ValueRow(title: "Esami con voto", value: transcript.gradedExams.count.formatted())
            ValueRow(title: "Esami pianificati", value: transcript.plannedCount.formatted())
            ValueRow(title: "CFU pianificati", value: transcript.plannedCredits.formatted(LibrettoFormat.credits))
            if !transcript.excludedIDs.isEmpty {
                ValueRow(title: "Voti esclusi dalla media", value: transcript.excludedIDs.count.formatted())
            }
        }
    }
}

#Preview("Light") {
    List {
        StatisticsSection(transcript: Transcript([
            ExamRecord(credits: 12, result: .graded(.mark(24)), date: .now.addingTimeInterval(-86_400)),
            ExamRecord(credits: 6, result: .graded(.mark(30)), date: .now),
            ExamRecord(credits: 6, result: .pending, date: nil),
        ], rules: .standard), names: [:])
    }
    .tint(SbuTheme.accentLibretto)
}

#Preview("Dark") {
    List {
        StatisticsSection(transcript: Transcript([], rules: .standard), names: [:])
    }
    .tint(SbuTheme.accentLibretto)
    .preferredColorScheme(.dark)
}
