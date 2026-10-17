import SbuKit
import SwiftUI

/// The figure of the report: the share of due doses taken in the period.
struct ReportFigure: View {
    let adherence: Adherence

    var body: some View {
        let value = (adherence.rate ?? 0).formatted(.percent.precision(.fractionLength(0)))
        SbuFigure(
            value: value,
            fullStop: adherence.rate == nil ? .waiting : .set,
            context: Text(context),
            accessibilityLabel: Text("Dosi prese: \(value). \(Text(context))")
        )
        .accessibilityIdentifier("reportFigure")
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, SbuTheme.space4)
        // Plain paper, not the grid: the figure sits above List rows. It still gives the figure its grid space.
        .sbuPaper(grid: false)
    }

    private var context: LocalizedStringKey {
        adherence.counted == 0
            ? "dosi prese · nessuna dose prevista nel periodo"
            : "dosi prese · prese \(adherence.taken), saltate \(adherence.skipped), non segnate \(adherence.missed)"
    }
}

#Preview("Light") {
    ReportFigurePreview()
}

#Preview("Dark") {
    ReportFigurePreview()
        .preferredColorScheme(.dark)
}

private struct ReportFigurePreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space4) {
            ReportFigure(adherence: Adherence(taken: 52, skipped: 2, missed: 3))
            ReportFigure(adherence: Adherence(taken: 0, skipped: 0, missed: 0))
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(SbuTheme.paper)
        .environment(\.sbuAccent, .meds)
    }
}
