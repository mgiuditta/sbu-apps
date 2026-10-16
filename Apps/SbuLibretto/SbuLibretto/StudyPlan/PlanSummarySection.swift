import SbuKit
import SwiftUI

/// The summary at the top of the study plan, as in the original: average, credits, and what is planned.
struct PlanSummarySection: View {
    let transcript: Transcript

    var body: some View {
        Section {
            ValueRow(title: "Media", value: transcript.weightedAverage?.formatted(LibrettoFormat.average) ?? "–")
            ValueRow(title: "CFU acquisiti", value: "\(transcript.earnedCredits.formatted(LibrettoFormat.credits)) / \(transcript.rules.totalCredits.formatted(LibrettoFormat.credits))")
            ValueRow(title: "Esami pianificati", value: transcript.plannedCount.formatted())
            ValueRow(title: "CFU pianificati", value: transcript.plannedCredits.formatted(LibrettoFormat.credits))
        }
    }
}

#Preview("Light") {
    List {
        PlanSummarySection(transcript: Transcript([
            ExamRecord(credits: 12, result: .graded(.mark(24)), date: nil),
            ExamRecord(credits: 6, result: .pending, date: nil),
        ], rules: .standard))
    }
}

#Preview("Dark") {
    List {
        PlanSummarySection(transcript: Transcript([], rules: .standard))
    }
    .preferredColorScheme(.dark)
}
