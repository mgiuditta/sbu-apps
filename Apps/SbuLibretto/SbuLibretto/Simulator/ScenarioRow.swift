import SbuKit
import SwiftUI

/// One grade of the simulator: the grade, the new average with the base under it, and the change
/// with its arrow, as the original's Voto / Nuova media / Diff.
struct ScenarioRow: View {
    let row: SimulationRow

    @ScaledMetric(relativeTo: .body) private var gradeWidth = 48

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space3) {
            Text(verbatim: row.grade.shortText)
                .font(SbuTheme.headline)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.ink)
                .frame(minWidth: gradeWidth, alignment: .leading)
            VStack(alignment: .leading, spacing: 0) {
                Text(row.average, format: LibrettoFormat.average)
                    .font(SbuTheme.body)
                    .monospacedDigit()
                    .foregroundStyle(SbuTheme.ink)
                Text("Base \(LibrettoFormat.base(row.base.value))")
                    .font(SbuTheme.footnote)
                    .monospacedDigit()
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            Spacer(minLength: SbuTheme.space2)
            if let change = row.change {
                ChangeLabel(change: change)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: spokenGrade))
        .accessibilityValue(Text(spokenValue))
    }

    private var spokenGrade: String {
        row.grade.isCumLaude ? String(localized: "30 e lode") : row.grade.mark.formatted()
    }

    private var spokenValue: LocalizedStringKey {
        let average = row.average.formatted(LibrettoFormat.average)
        let base = LibrettoFormat.base(row.base.value)
        guard let change = row.change else { return "Nuova media \(average), base \(base)" }
        return "Nuova media \(average), \(change.formatted(LibrettoFormat.change)), base \(base)"
    }
}

#Preview("Light") {
    List {
        ForEach(Simulation([ExamRecord(credits: 91, result: .graded(.mark(28)), date: nil)], rules: .standard, credits: 6).rows) { row in
            ScenarioRow(row: row)
        }
    }
}

#Preview("Dark") {
    List {
        ForEach(Simulation([], rules: .standard, credits: 6).rows) { row in
            ScenarioRow(row: row)
        }
    }
    .preferredColorScheme(.dark)
}
