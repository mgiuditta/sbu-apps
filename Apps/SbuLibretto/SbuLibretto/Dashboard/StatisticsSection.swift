import SbuKit
import SwiftUI

/// The statistics under the figure: how the average went, then the secondary figures.
struct StatisticsSection: View {
    let transcript: Transcript
    let names: [ExamRecord.ID: String]

    var body: some View {
        CardSection("Andamento media") {
            AverageChart(points: transcript.trend, names: names)
                .padding(.horizontal, SbuTheme.space4)
        }
        CardSection("Statistiche") {
            SbuListCard(values) { value in
                ValueRow(title: value.title, value: value.value)
            }
        }
    }

    private var values: [StatisticValue] {
        var values: [StatisticValue] = []
        if let arithmetic = transcript.arithmeticAverage {
            values.append(StatisticValue(id: "arithmetic", title: "Media aritmetica", value: arithmetic.formatted(LibrettoFormat.average)))
        }
        if let base = transcript.base {
            values.append(StatisticValue(id: "base", title: "Base di laurea", value: base.text))
        }
        values.append(StatisticValue(id: "graded", title: "Esami con voto", value: transcript.gradedExams.count.formatted()))
        values.append(StatisticValue(id: "planned", title: "Esami pianificati", value: transcript.plannedCount.formatted()))
        values.append(StatisticValue(id: "plannedCredits", title: "CFU pianificati",
                                     value: transcript.plannedCredits.formatted(LibrettoFormat.credits)))
        if !transcript.excludedIDs.isEmpty {
            values.append(StatisticValue(id: "excluded", title: "Voti esclusi dalla media", value: transcript.excludedIDs.count.formatted()))
        }
        return values
    }
}

#Preview("Light") {
    ScrollView {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            StatisticsSection(transcript: Transcript([
                ExamRecord(credits: 12, result: .graded(.mark(24)), date: .now.addingTimeInterval(-86_400)),
                ExamRecord(credits: 6, result: .graded(.mark(30)), date: .now),
                ExamRecord(credits: 6, result: .pending, date: nil),
            ], rules: .standard), names: [:])
        }
        .padding(SbuTheme.space4)
    }
    .background(SbuTheme.paper)
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    ScrollView {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            StatisticsSection(transcript: Transcript([], rules: .standard), names: [:])
        }
        .padding(SbuTheme.space4)
    }
    .background(SbuTheme.paper)
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
