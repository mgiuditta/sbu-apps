import SbuKit
import SwiftUI

/// Why the lesson cannot be saved, or which lessons it overlaps: a hint, never a block.
struct LessonFormFooter: View {
    let problem: LessonDraft.Problem?
    let overlaps: [LessonSlot]

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            if problem == .endNotAfterStart {
                Label {
                    Text("La fine deve venire dopo l'inizio.")
                } icon: {
                    Image(systemName: "exclamationmark.circle")
                        .fontWeight(.medium)
                }
                .foregroundStyle(SbuTheme.danger)
                .accessibilityIdentifier("lessonProblem")
            }
            ForEach(overlaps) { other in
                Text("Si sovrappone a \(other.title), \(other.start.text)–\(other.end.text).")
            }
            Text("Gli orari restano come li imposti, senza scambi tra mattina e pomeriggio.")
        }
    }
}

#Preview("Light") {
    Form {
        Section {
        } footer: {
            LessonFormFooter(problem: .endNotAfterStart, overlaps: [])
        }
    }
}

#Preview("Dark") {
    Form {
        Section {
        } footer: {
            LessonFormFooter(problem: nil, overlaps: [LessonSlot(id: UUID(), title: "Reti", room: "", weekday: 2,
                                                                 start: ClockTime(hour: 9, minute: 0), end: ClockTime(hour: 10, minute: 0))])
        }
    }
    .preferredColorScheme(.dark)
}
