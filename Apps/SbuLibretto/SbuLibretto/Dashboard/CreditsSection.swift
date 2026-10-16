import SbuKit
import SwiftUI

/// The credits earned out of the degree's total, with a bar, under the name of the course when you gave one.
struct CreditsSection: View {
    let transcript: Transcript
    let settings: CourseSettings

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                LabeledContent {
                    Text(verbatim: credits)
                        .monospacedDigit()
                        .foregroundStyle(SbuTheme.inkMuted)
                } label: {
                    Text("CFU acquisiti")
                        .foregroundStyle(SbuTheme.ink)
                }
                ProgressView(value: transcript.progress)
                    .accessibilityHidden(true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("CFU acquisiti"))
            .accessibilityValue(Text(verbatim: "\(credits), \(transcript.progress.formatted(.percent.precision(.fractionLength(0))))"))
            .accessibilityIdentifier("credits")
        } header: {
            if let header {
                Text(verbatim: header)
            }
        }
        .listRowBackground(SbuTheme.surfaceRaised)
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
    List {
        CreditsSection(transcript: Transcript([ExamRecord(credits: 91, result: .graded(.mark(28)), date: nil)], rules: .standard),
                       settings: LaunchMode.sample.courseSettings())
    }
    .tint(SbuTheme.accentLibretto)
}

#Preview("Dark") {
    List {
        CreditsSection(transcript: Transcript([], rules: .standard), settings: LaunchMode.empty.courseSettings())
    }
    .tint(SbuTheme.accentLibretto)
    .preferredColorScheme(.dark)
}
