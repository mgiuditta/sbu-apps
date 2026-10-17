import SbuKit
import SwiftUI

/// The figure of a medicine: doses taken in the last 30 days, and the share of the due ones.
struct MedicineFigure: View {
    let adherence: Adherence

    var body: some View {
        SbuFigure(
            value: adherence.taken.formatted(),
            fullStop: adherence.taken > 0 ? .set : .waiting,
            context: Text(context),
            accessibilityLabel: Text("Prese in 30 giorni: \(adherence.taken). \(Text(context))")
        )
        .accessibilityIdentifier("medicineFigure")
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, SbuTheme.space4)
        // Plain paper, not the grid: the figure sits above List rows. It still gives the figure its grid space.
        .sbuPaper(grid: false)
    }

    private var context: LocalizedStringKey {
        guard let rate = adherence.rate else { return "prese in 30 giorni · nessuna dose ancora passata" }
        return "prese in 30 giorni · \(rate.formatted(.percent.precision(.fractionLength(0)))) delle dosi previste"
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
        .frame(maxHeight: .infinity, alignment: .top)
        .background(SbuTheme.paper)
        .environment(\.sbuAccent, .meds)
    }
}
