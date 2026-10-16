import SbuKit
import SwiftUI

/// An exam in the study plan: name, credits and date, and on the right its grade, "Idoneo", or "?"
/// while it is still to take, as in the original.
struct ExamRow: View {
    let item: PlanItem
    let isExcluded: Bool

    @ScaledMetric(relativeTo: .title2) private var gradeSize = SbuTheme.statSmallSize

    var body: some View {
        LabeledContent {
            Text(verbatim: trailing)
                .font(SbuTheme.smallNumberFont(size: gradeSize))
                .foregroundStyle(item.result.isDone ? SbuTheme.ink : SbuTheme.inkMuted)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Text(item.name)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                Text(subtitle)
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        .padding(.vertical, SbuTheme.space1)
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(item.name))
        .accessibilityValue(Text(verbatim: "\(spokenResult), \(subtitle)"))
    }

    private var trailing: String {
        switch item.result {
        case let .graded(grade): grade.shortText
        case .passed: String(localized: "Idoneo")
        case .pending: "?"
        }
    }

    private var spokenResult: String {
        switch item.result {
        case let .graded(grade): grade.isCumLaude ? String(localized: "30 e lode") : grade.mark.formatted()
        case .passed: String(localized: "Idoneo")
        case .pending: String(localized: "Da sostenere")
        }
    }

    private var subtitle: String {
        var parts = [String(localized: "\(item.credits.formatted(LibrettoFormat.credits)) CFU")]
        if let date = item.date {
            let day = date.formatted(.dateTime.day().month(.abbreviated).year())
            parts.append(item.result.isDone ? day : String(localized: "appello \(day)"))
        } else if !item.result.isDone {
            parts.append(String(localized: "da sostenere"))
        }
        if isExcluded {
            parts.append(String(localized: "fuori media"))
        }
        return parts.joined(separator: " · ")
    }
}

#Preview("Light") {
    List {
        ExamRow(item: PlanItem(id: UUID(), name: "Analisi I", credits: 12, courseYear: 1, result: .graded(.cumLaude), date: .now), isExcluded: false)
        ExamRow(item: PlanItem(id: UUID(), name: "Reti di calcolatori", credits: 6, courseYear: 2, result: .pending, date: .now), isExcluded: false)
        ExamRow(item: PlanItem(id: UUID(), name: "Inglese", credits: 3, courseYear: 1, result: .passed, date: nil), isExcluded: false)
        ExamRow(item: PlanItem(id: UUID(), name: "Fisica", credits: 7.5, courseYear: 1, result: .graded(.mark(18)), date: nil), isExcluded: true)
    }
}

#Preview("Dark") {
    List {
        ExamRow(item: PlanItem(id: UUID(), name: "Sistemi operativi", credits: 9, courseYear: 2, result: .pending, date: nil), isExcluded: false)
    }
    .preferredColorScheme(.dark)
}
