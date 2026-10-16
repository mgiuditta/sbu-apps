import SbuKit
import SwiftUI

/// The empty state of the first launch: add your first exam, or look around with a sample libretto.
/// No university to pick first: the name is optional, in Settings.
struct FirstExamView: View {
    let addExam: () -> Void
    let addSample: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: SbuTheme.space6) {
                VStack(spacing: SbuTheme.space2) {
                    Image(systemName: "book.closed")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .accessibilityHidden(true)
                    Text("Il tuo libretto è vuoto")
                        .font(SbuTheme.title2)
                        .foregroundStyle(SbuTheme.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("Registra i voti che hai e gli esami che ti mancano: vedi subito la media, i CFU e la base di laurea.")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                VStack(spacing: SbuTheme.space3) {
                    SbuButton("Registra voto", action: addExam)
                        .accessibilityIdentifier("addFirstExam")
                    SbuButton("Prova con dati di esempio", kind: .secondary, action: addSample)
                        .accessibilityIdentifier("addSample")
                }
            }
            .padding(SbuTheme.space4)
            .frame(maxWidth: .infinity)
        }
        .defaultScrollAnchor(.center)
        .scrollBounceBehavior(.basedOnSize)
        .background(SbuTheme.surface)
    }
}

#Preview("Light") {
    FirstExamView(addExam: {}, addSample: {})
        .tint(SbuTheme.accentLibretto)
}

#Preview("Dark") {
    FirstExamView(addExam: {}, addSample: {})
        .tint(SbuTheme.accentLibretto)
        .preferredColorScheme(.dark)
}
