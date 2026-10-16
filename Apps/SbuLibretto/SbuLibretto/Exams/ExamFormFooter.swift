import SbuKit
import SwiftUI

/// Why the exam cannot be saved yet, in words; nothing while the fields are simply empty.
struct ExamFormFooter: View {
    let problem: ExamDraft.Problem?
    let isDuplicate: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            if let message {
                Label {
                    Text(message)
                } icon: {
                    Image(systemName: "exclamationmark.circle")
                        .fontWeight(.medium)
                }
                .foregroundStyle(SbuTheme.danger)
                .accessibilityIdentifier("examProblem")
            }
            if isDuplicate {
                Text("C'è già un esame con questo nome nel libretto.")
            }
            Text("CFU anche decimali, per esempio 7,5.")
        }
    }

    private var message: LocalizedStringKey? {
        switch problem {
        case .invalidCredits: "Scrivi i crediti come numero, per esempio 6 o 7,5."
        case .creditsOutOfRange: "Un esame ha da 0,5 a 60 CFU."
        case .futureDate: "Un voto non può avere una data futura. Se non l'hai ancora sostenuto, spegni Sostenuto."
        case .missingName, .missingCredits, nil: nil
        }
    }
}

#Preview("Light") {
    Form {
        Section {
            Text(verbatim: "7,,5")
        } footer: {
            ExamFormFooter(problem: .invalidCredits, isDuplicate: true)
        }
    }
}

#Preview("Dark") {
    Form {
        Section {
            Text(verbatim: "Analisi I")
        } footer: {
            ExamFormFooter(problem: nil, isDuplicate: false)
        }
    }
    .preferredColorScheme(.dark)
}
