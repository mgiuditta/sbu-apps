import SbuKit
import SwiftUI

/// The figure of a medicine: doses taken in the last 30 days, and the share of the due ones.
struct MedicineFigure: View {
    let adherence: Adherence

    var body: some View {
        SbuStat("Prese in 30 giorni", value: adherence.taken, format: .number, context: context)
            .accessibilityIdentifier("medicineFigure")
    }

    private var context: LocalizedStringKey {
        guard let rate = adherence.rate else { return "Nessuna dose ancora passata" }
        return "\(rate.formatted(.percent.precision(.fractionLength(0)))) delle dosi previste"
    }
}

#Preview("Light") {
    MedicineFigurePreview()
}

#Preview("Dark") {
    MedicineFigurePreview()
        .preferredColorScheme(.dark)
}

private struct MedicineFigurePreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space4) {
            MedicineFigure(adherence: Adherence(taken: 27, skipped: 1, missed: 2))
            MedicineFigure(adherence: Adherence(taken: 0, skipped: 0, missed: 0))
        }
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentMeds)
    }
}
