import SbuKit
import SwiftUI

/// The empty state of the first launch: add your first exam, or look around with a sample libretto.
/// No university to pick first: the name is optional, in Settings.
struct FirstExamView: View {
    let addExam: () -> Void
    let addSample: () -> Void

    var body: some View {
        SbuEmpty(sentence: "Registra i voti che hai e gli esami che ti mancano: vedi subito la media, i CFU e la base di laurea.") {
            VStack(spacing: SbuTheme.space3) {
                SbuButton("Registra voto", action: addExam)
                    .accessibilityIdentifier("addFirstExam")
                SbuButton("Prova con dati di esempio", kind: .secondary, action: addSample)
                    .accessibilityIdentifier("addSample")
            }
        }
    }
}

#Preview("Light") {
    FirstExamView(addExam: {}, addSample: {})
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: true)
}

#Preview("Dark") {
    FirstExamView(addExam: {}, addSample: {})
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: true)
        .preferredColorScheme(.dark)
}
