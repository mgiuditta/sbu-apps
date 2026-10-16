import SbuKit
import SwiftUI

/// The figure of the report: the share of due doses taken in the period.
struct ReportFigure: View {
    let adherence: Adherence

    var body: some View {
        SbuStat("Dosi prese", value: adherence.rate ?? 0, format: .percent.precision(.fractionLength(0)), context: context)
            .accessibilityIdentifier("reportFigure")
    }

    private var context: LocalizedStringKey {
        adherence.counted == 0
            ? "Nessuna dose prevista nel periodo"
            : "Prese \(adherence.taken), saltate \(adherence.skipped), non segnate \(adherence.missed)"
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
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentMeds)
    }
}
