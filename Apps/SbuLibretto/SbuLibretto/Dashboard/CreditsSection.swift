import SbuKit
import SwiftUI

/// The credits earned out of the degree's total, with a bar in ink, under the name of the course when you gave one.
struct CreditsSection: View {
    let transcript: Transcript
    let settings: CourseSettings

    var body: some View {
        CardSection(title: header.map { Text(verbatim: $0) }) {
            SbuListCard([StatisticValue(id: "credits", title: "CFU acquisiti", value: credits)]) { row in
                VStack(alignment: .leading, spacing: SbuTheme.space2) {
                    LabeledContent {
                        Text(verbatim: row.value)
                            .monospacedDigit()
                            .foregroundStyle(SbuTheme.inkMuted)
                    } label: {
                        Text(row.title)
                            .foregroundStyle(SbuTheme.ink)
                    }
                    ProgressView(value: transcript.progress)
                        .tint(SbuTheme.ink)
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(row.title))
                .accessibilityValue(Text(verbatim: "\(row.value), \(transcript.progress.formatted(.percent.precision(.fractionLength(0))))"))
                .accessibilityIdentifier("credits")
            }
        }
    }

    private var credits: String {
        "\(transcript.earnedCredits.formatted(LibrettoFormat.credits)) / \(transcript.rules.totalCredits.formatted(LibrettoFormat.credits))"
    }

    /// "Ingegneria informatica · Politecnico di Milano", or what of it you set.
    private var header: String? {
        let parts = [settings.course, settings.university]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}

#Preview("Light") {
    CreditsSection(transcript: Transcript([ExamRecord(credits: 91, result: .graded(.mark(28)), date: nil)], rules: .standard),
                   settings: LaunchMode.sample.courseSettings())
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: false)
}

#Preview("Dark") {
    CreditsSection(transcript: Transcript([], rules: .standard), settings: LaunchMode.empty.courseSettings())
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: false)
        .preferredColorScheme(.dark)
}
